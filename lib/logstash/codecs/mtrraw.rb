# encoding: utf-8
require "logstash/codecs/base"
require "logstash/codecs/line"
require "logstash/namespace"
require "securerandom"
require "digest"
require 'awesome_print'

class MtrRec
	attr_accessor :type,:id,:data
	def initialize(line)
		parts = line.split(/\s+/,3)
		@type = parts[0]
		@id = parts[1]
		@data = parts[2]
	end
end

class MtrHost
	attr_accessor :hostid,:addr,:pings,:dns,:recs,:totalreplies
	def initialize(rec,pingcount,recs)
		@hostid = rec.id
		@addr = rec.data
		@recs = recs
		@pings = recs.select{|each| each.type == 'p'}.collect {|each|each.data}
		@pingloss = (100.to_f - (100.to_f * (@pings.size.to_f / pingcount.to_f))).to_i if pingcount.to_i > 0
		@avgrtt = (@pings.inject(0.0) {|counter,each| counter += (each.to_f/1000)} / @pings.size).to_i
		@dns = recs.select{|each| each.type =='d'}.collect {|each|each.data}.pop
	end
	def to_event_struct
		{:hostid => @hostid, :addr => @addr , :pings => @pings ,:dns => @dns,:pingloss => @pingloss,:avgrtt => @avgrtt}
	end
end 

class LogStash::Codecs::Mtrraw < LogStash::Codecs::Base

  # The codec name
  config_name "mtrraw"

  # Append a string to the message
  # config :append, :validate => :string, :default => ', Hello World!'

  def register
  end # def register

  def decode(data)
    mtrlines = data.split(';')
    mtrrecs = mtrlines.collect {|each| MtrRec.new(each) }
    if mtrrecs[0].type == 's'
    	target = mtrrecs.shift.data
	pingcount = 0
	if target =~ /(\S+) (\S+) (\d+)/
		origin = $1
		target = $2
		pingcount = $3
	elsif target =~ /(\S+) (\d+)/
		origin = "ORIGIN"
		target = $1
		pingcount = $2
	end
    end
    id = SecureRandom.uuid
    hops = Array.new
    mtrrecs.each { |rec|
	if rec.type == 'h'
		hop = MtrHost.new(rec,pingcount,mtrrecs.select{|each| each.id == rec.id }).to_event_struct
		if hops.size > 1
			if (hops[hops.size - 1][:addr] != hop[:addr])
				hops.push(hop)
			else
				# It's a duplicate of the last hop - drop it
			end
		else
			hops.push(hop)
		end
	end
    }
    path = hops.collect {|each|each[:addr]}
    pathsig = Digest::MD5.hexdigest(path.join('-'))
    avgloss = hops.inject(0) {|loss,each| loss += each[:pingloss]} / path.size
    avgrtt = hops.inject(0.0) {|rtt,each| rtt += each[:avgrtt]} / path.size
    tracedata = { 	"id" => id,
			"origin" => origin,
			"target" => target,
			"message" => data ,
			"hops" => hops,
			"path" => path ,
			"pathsig" => pathsig,
			"pingcount"=>pingcount,
			"avgloss"=>avgloss,
			"avgrtt" => avgrtt,
			"tags" => ["wholepath"]
	}
    wholepathevent = LogStash::Event.new(tracedata)
    yield wholepathevent
    # Construct a starting point for trace to target
    yield LogStash::Event.new({
	"id" => id,
	"origin" => origin,
	"target" => target,
	"tags" => ["hop"],
	"seq" => -1,
	"pathsig" => pathsig,
	"A_node" => "#{origin}->#{target}",
	"Z_node" => hops[0][:addr],
	"dns" => origin,
	"avgrtt" => 0,
	"pingloss" => 0
    })
    0.upto(path.size - 2) {
       |index|
       yield LogStash::Event.new({	"id" => id,
					"origin" => origin,
					"target" => target,
                                   	"tags" => ["hop"],
					"pathsig" => pathsig,
					"seq" => index,
 					"A_node" => hops[index][:addr],
					"Z_node" => hops[index + 1][:addr],
					"dns" => hops[index + 1][:dns],
					"avgrtt" => hops[index + 1][:avgrtt],
					"pingloss" => hops[index + 1][:pingloss]
	})
    }
  end # def decode

  def encode_sync(event)
    # Nothing to do.
    @on_event.call(event, event)
  end # def encode_sync

end # class LogStash::Codecs::Mtrraw

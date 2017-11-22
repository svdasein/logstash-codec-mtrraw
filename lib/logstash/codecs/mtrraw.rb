# encoding: utf-8
require "logstash/codecs/base"
require "logstash/codecs/line"
require "logstash/namespace"
require "awesome_print"


# This codec presumes you've somehow sent in the equivalent of this
# bash one-liner:
# (echo "S MYTARGET" ; mtr --raw -c <samplecount> 8.8.8.8) | awk '{printf $1";"}'
# You can get that into logstash any way you want, e.g. netcat will
# work if you set up a tcp input:
# (echo "S MYTARGET" ; mtr --raw -c <samplecount> 8.8.8.8) | awk '{printf $1";"}' | nc <myserver> <myport>
#

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
		@pingloss = 100.to_f - (100.to_f * (@pings.size.to_f / pingcount.to_f)) if pingcount.to_i > 0
		@avgrtt = @pings.inject(0.0) {|counter,each| counter += each.to_f} / @pings.size
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
	if target =~ /(\w+) (\d+)/
		target = $1
		pingcount = $2
	end
    end
    hops = Array.new
    mtrrecs.each { |rec|
	if rec.type == 'h'
		hops.push(MtrHost.new(rec,pingcount,mtrrecs.select{|each| each.id == rec.id }).to_event_struct)
	end
    }
    path = hops.collect {|each|each[:addr]}
    avgloss = hops.inject(0) {|loss,each| loss += each[:pingloss]} / path.size
    avgrtt = hops.inject(0.0) {|rtt,each| rtt += each[:avgrtt]} / path.size
    tracedata = { "target" => target, "message" => data , "hops" => hops,"path" => path ,"pingcount"=>pingcount,"avgloss"=>avgloss, "avgrtt" => avgrtt}
    yield LogStash::Event.new(tracedata)
  end # def decode

  # Encode a single event, this returns the raw data to be returned as a String
  def encode_sync(event)
    # Nothing to do.
    @on_event.call(event, event)
  end # def encode_sync

end # class LogStash::Codecs::Mtrraw

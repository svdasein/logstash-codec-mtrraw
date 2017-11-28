# logstash-codec-mtrraw

This is a codec plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

The logstash mtrraw codec wraps together a bunch of logic that makes it easy to use mtr --raw output in your ELK infrastructure (or whatever you're
sending logstash data to).

### Installation

```
bin/logstash-plugin install logstash-codec-mtrraw
```
### Configuration

```
input {
        tcp {
                port => 4327
                codec => "mtrraw"
        }
}
```

### Sending MTR trace data
Feed it with something that's functionally equivalent to this:

```
while true ; do (echo "s 0 MYBOX GOOGDNS 1";mtr --raw --no-dns  -c 1 8.8.8.8 ) | awk '{printf $0";"}'  | nc localhost 4327 ; done
```

Put the above in a script, make the script executable, and run it in the background.  It'll continuously feed mtr trace data to
the codec.

The `agent` subdirectory contains some examples of this.  You may have to play around with paths etc to make it work on your
system.

Explanation:

There's an infinite loop around the traces without a pause.  A pause isn't really needed to keep load down as the trace is i/o bound
on the network all the time anyway.

The `(echo ...;mtr)` construct allows us to overload the frontend of the trace a little bit and have the whole thing treated as a single
stream.  The front of the trace has a line that looks like this:

```
s 0 <originname> <targetname> <pingcount>

```

* <originname> is a name for the starting point of the trace
* <targetname> is whatever name you want to give the trace
* <pingcount> is the number of pings you're going to be doing to each node in the trace. This must match the -c parameter to mtr (see below).


The MTR execution part requires the following:

* You must use the `--raw` output format
* You must specify the `-c` (count) option to state how many pings you want to do. This number must also be in the start line (above)

Any other options are optional :)

The `| awk '{printf $0";"}` construct takes all the --raw output lines and puts them together in one line delimited by semicolons.  This
in turn is sent to your logstash instance at the port you defined when you configured it using a tcp connection via the netcat (nc) command.

### What you'll get

The codec generates two kinds of documents:

#### wholepath

Whole path documents are identified by the "wholepath" tag.  These documents describe the entire path taken and assign a signature to the path you can 
use to identify it among paths taken.  This allows you to e.g. do route flap detection, rtt & loss analysis, etc.

#### hop

Hop documents are identified by the "hop" tag.  These documents describe a single hop on a path (where the path is identified by the same identifier
that the wholepath document contains).  You can use these with the excellent [Network visualization plugin](https://github.com/dlumbrer/kbn_network)  to visualize routes in kibana.


## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.

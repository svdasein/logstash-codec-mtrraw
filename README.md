# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

The logstash mtrraw codec wraps together a bunch of logic that makes it easy to use mtr --raw output in your ELK infrastructure.  

To install it, do

.Installation
 bin/logstash-plugin install logstash-codec-mtrraw

Configure it like this:

.Logstash input configuration example
[source,ruby]
-------------------------------------------
input {
        tcp {
                port => 4327
                codec => "mtrraw"
        }
}
-------------------------------------------


## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.

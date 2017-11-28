Gem::Specification.new do |s|
  s.name          = 'logstash-codec-mtrraw'
  s.version       = '0.2.3'
  s.licenses      = ['Apache License (2.0)']
  s.summary       = 'Converts optionally overloaded mtr --raw data to an event'
  s.description   = 'Translate mtr --raw traces into logstash events'
  s.homepage      = 'https://github.com/svdasein/logstash-codec-mtrraw'
  s.authors       = ['svdasein']
  s.email         = 'daveparker01@gmail.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['agent/*','lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "codec" }

  # Gem dependencies
  s.add_runtime_dependency 'logstash-core-plugin-api', "~> 2.0"
  s.add_runtime_dependency 'logstash-codec-line'
  s.add_development_dependency 'logstash-devutils'
end

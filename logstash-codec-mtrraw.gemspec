Gem::Specification.new do |s|
  s.name          = 'logstash-codec-mtrraw'
  s.version       = '0.2.3'
  s.licenses      = ['Apache License (2.0)']
  s.summary       = 'Converts mtr --raw route trace data to logstash events'
  s.description   = 'Renders wholepath and hop record types from mtr --raw path trace data'
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

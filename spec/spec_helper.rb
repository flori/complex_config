begin
  require 'gem_hadar/simplecov'
  GemHadar::SimpleCov.start
rescue LoadError
end
require 'rspec'
begin
  require 'debug'
rescue LoadError
end
require 'complex_config'

def config_dir
  Pathname.new(__FILE__).dirname + "config"
end

def asset(name)
  config_dir + name
end

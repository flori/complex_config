if ENV['START_SIMPLECOV'].to_i == 1
  require 'simplecov'
  SimpleCov.start do
    add_filter "#{File.basename(File.dirname(__FILE__))}/"
  end
end

if ENV.key?('CODECLIMATE_REPO_TOKEN')
  begin
    require "codeclimate-test-reporter"
  rescue LoadError => e
    warn "Caught #{e.class}: #{e.message} loading codeclimate-test-reporter"
  else
    CodeClimate::TestReporter.start
  end
end

require 'rspec'
begin
  require 'byebug'
rescue LoadError
end
require 'complex_config'

def config_dir
  Pathname.new(__FILE__).dirname + "config"
end

def asset(name)
  config_dir + name
end

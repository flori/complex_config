require 'set'
require 'erb'
require 'pathname'
require 'yaml'

class ComplexConfig::Provider
  include Tins::SexySingleton

  def initialize
    @plugins     = Set.new
    @deep_freeze = true
  end

  attr_reader :plugins

  def add_plugin(plugin)
    plugins.add plugin
    self
  end

  attr_writer :deep_freeze

  def deep_freeze?
    !!@deep_freeze
  end

  def apply_plugins(setting, id)
    plugins.find do |plugin|
      catch :skip do
        value = setting.instance_exec(id, &plugin) and return value
      end
      nil
    end
  end

  def pathname(name)
    root + "config/#{name}.yml"
  end

  def config(pathname, name = nil)
    result = evaluate(pathname)
    hash = ::YAML.load(result, pathname)
    ComplexConfig::Settings.build(name, hash).tap do |settings|
      deep_freeze? and settings.deep_freeze
    end
  rescue ::Errno::ENOENT => e
    raise ComplexConfig::ComplexConfigError.wrap(:ConfigurationFileMissing, e)
  rescue ::Psych::SyntaxError => e
    raise ComplexConfig::ComplexConfigError.wrap(:ConfigurationSyntaxError, e)
  end

  def [](name)
    config pathname(name), name
  end
  memoize_method :[]

  def proxy(env = nil)
    ComplexConfig::Proxy.new(env)
  end

  def flush_cache
    memoize_cache_clear
    self
  end

  def evaluate(pathname)
    data = File.read pathname
    erb = ::ERB.new(data)
    erb.filename = pathname.to_s
    erb.result
  end

  attr_writer :root

  def root
    @root || defined?(Rails) && Rails.root || Pathname.pwd
  end

  attr_writer :env

  def env
    @env || defined?(Rails) && Rails.env || ENV['RAILS_ENV'] || 'development'
  end
end

require 'set'
require 'erb'
require 'pathname'
require 'yaml'
require 'mize'

class ComplexConfig::Provider
  include Tins::SexySingleton
  include ComplexConfig::Provider::Shortcuts

  def initialize
    @plugins     = Set.new
    @deep_freeze = true
  end

  def configure_with(config)
    config.configure(self)
    flush_cache
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

  def config_dir=(dir)
    if dir.nil?
      @config_dir = nil
    else
      @config_dir = Pathname.new(dir)
    end
  end

  def config_dir
    @config_dir || (defined?(Rails) && Rails.root || Pathname.pwd) + 'config'
  end

  def pathname(name)
    config_dir + "#{name}.yml"
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
  memoize method: :[]

  def proxy(env = nil)
    ComplexConfig::Proxy.new(env)
  end
  memoize method: :proxy

  def flush_cache
    mize_cache_clear
    self
  end

  def evaluate(pathname)
    data = File.read pathname
    erb = ::ERB.new(data)
    erb.filename = pathname.to_s
    erb.result
  end

  def env
    @env || defined?(Rails) && Rails.env || ENV['RAILS_ENV'] || 'development'
  end

  attr_writer :env
end

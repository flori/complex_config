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
    datas = []
    if File.exist?(pathname)
      datas << IO.binread(pathname)
    end
    if enc_pathname = pathname.to_s + '.enc' and File.exist?(enc_pathname)
      key = key(pathname)
      text = IO.binread(enc_pathname)
      datas << ComplexConfig::Encryption.new(key).decrypt(text)
    end
    datas.empty? and raise ComplexConfig::ConfigurationFileMissing,
      "configuration file #{pathname.inspect} is missing"
    results = datas.map { |d| evaluate(pathname, d) }
    hashes = results.map { |r| ::YAML.load(r, pathname) }
    settings = ComplexConfig::Settings.build(name, hashes.first)
    hashes[1..-1]&.each { |h| settings.attributes_update(h) }
    if shared = settings.shared?
      shared = shared.to_h
      settings.each do |key, value|
        if value.is_a? ComplexConfig::Settings
          value.attributes_update(shared)
        end
      end
    end
    deep_freeze? and settings.deep_freeze
    settings
  rescue ::Psych::SyntaxError => e
    raise ComplexConfig::ComplexConfigError.wrap(:ConfigurationSyntaxError, e)
  end

  def [](name)
    config pathname(name), name
  end
  memoize method: :[]

  def exist?(name)
    !!config(pathname(name), name)
  rescue ComplexConfig::ConfigurationFileMissing
    false
  end

  def proxy(env = nil)
    ComplexConfig::Proxy.new(env)
  end
  memoize method: :proxy

  def flush_cache
    mize_cache_clear
    self
  end

  def evaluate(pathname, data)
    erb = ::ERB.new(data)
    erb.filename = pathname.to_s
    erb.result
  end

  def env
    @env || defined?(Rails) && Rails.env || ENV['RAILS_ENV'] || 'development'
  end

  attr_writer :env

  def key(pathname = nil)
    key = [
      @key,
      read_key_from_file(pathname),
      ENV['RAILS_MASTER_KEY']
    ].compact[0, 1]
    unless key.empty?
      key.pack('H*')
    end
  end

  attr_writer :key

  private

  def read_key_from_file(pathname)
    if pathname
      IO.binread(pathname.to_s + '.key')
    end
  rescue Errno::ENOENT
  end
end


require 'set'
require 'erb'
require 'pathname'
require 'yaml'
require 'mize'
require 'tins/xt/secure_write'

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

  def deep_freeze=(flag)
    if @deep_freeze && !flag
      mize_cache_clear
    end
    @deep_freeze = flag
  end

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
    if enc_pathname = pathname.to_s + '.enc' and
      File.exist?(enc_pathname) and
      my_key = key_as_bytes(enc_pathname)
    then
      text = IO.binread(enc_pathname)
      datas << ComplexConfig::Encryption.new(my_key).decrypt(text)
    end
    datas.empty? and raise ComplexConfig::ConfigurationFileMissing,
      "configuration file #{pathname.to_s.inspect} is missing"
    results = datas.map { |d| evaluate(pathname, d) }
    hashes = results.map { |r| ::YAML.load(r, pathname) }
    settings = ComplexConfig::Settings.build(name, hashes.shift)
    hashes.each { |h| settings.attributes_update(h) }
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

  def write_config(name, value: nil, encrypt: false, store_key: false)
    name, value = interpret_name_value(name, value)
    config_pathname = pathname(name).to_s
    if encrypt
      key = provide_key(config_pathname, encrypt)
      kb = key_to_bytes(key)
      File.secure_write(config_pathname + '.enc') do |out|
        out.write ComplexConfig::Encryption.new(kb).encrypt(prepare_output(value))
      end
      if store_key
        File.secure_write(config_pathname + '.key') do |out|
          out.write key
        end
      end
      key
    else
      File.secure_write(config_pathname) do |out|
        out.puts prepare_output(value)
      end
      true
    end
  ensure
    flush_cache
  end

  def prepare_output(value)
    value.each_with_object({}) do |(k, v), h|
      h[k.to_s] = v
    end.to_yaml
  end

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
    [
      @key,
      read_key_from_file(pathname),
      ENV['COMPLEX_CONFIG_KEY'],
      ENV['RAILS_MASTER_KEY'],
    ].compact[0, 1].map(&:strip).first
  end

  def key_as_bytes(pathname)
    if k = key(pathname.sub(/\.enc\z/, ''))
      key_to_bytes(k)
    else
      warn "encryption key is missing for #{pathname.to_s.inspect} => Ignoring it!"
      nil
    end
  end

  attr_writer :key

  private

  def interpret_name_value(name, value)
    if ComplexConfig::Settings === name
      if value
        name = name.name_prefix
      else
        value = name.to_h
        name  = name.name_prefix
      end
    elsif name.respond_to?(:to_sym)
      value = value.to_h
    else
      raise ArgumentError, "name has to be either string/symbol or ComplexConfig::Settings"
    end
    return name, value
  end

  def provide_key(pathname, encrypt)
    key = case encrypt
    when :random
      SecureRandom.hex(16)
    when true
      key(pathname)
    when String
      if encrypt =~ /\A\h{32}\z/
        encrypt
      else
        raise ComplexConfig::EncryptionKeyInvalid,
          "encryption key has wrong format, has to be hex number of length "\
          "32, was #{encrypt.inspect}"
      end
    end
    key or raise ComplexConfig::EncryptionKeyInvalid, "encryption key is missing"
  end

  def key_to_bytes(key)
    [ key ].pack('H*')
  end

  def read_key_from_file(pathname)
    if pathname
      IO.binread(pathname.to_s + '.key')
    end
  rescue Errno::ENOENT
  end
end


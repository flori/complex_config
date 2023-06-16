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

  attr_writer :master_key_pathname

  def master_key_pathname
    if @master_key_pathname
      @master_key_pathname
    else
      config_dir + 'master.key'
    end
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
    @config_dir || (defined?(Rails) && Rails.respond_to?(:root) && Rails.root || Pathname.pwd) + 'config'
  end

  def pathname(name)
    config_dir + "#{name}.yml"
  end

  def decrypt_config(pathname)
    decrypt_config_case(pathname).first
  end

  def encrypt_config(pathname, config)
    ks = key_source(pathname)
    ComplexConfig::Encryption.new(ks.key_bytes).encrypt(config)
  end

  def config(pathname, name = nil)
    datas = []
    path_exist = File.exist?(pathname)
    if path_exist
      datas << IO.binread(pathname)
    end
    decrypted, reason, enc_pathname = decrypt_config_case(pathname)
    case reason
    when :ok
      datas << decrypted
    when :key_missing
      datas.empty? and raise ComplexConfig::EncryptionKeyMissing,
        "encryption key for #{enc_pathname.to_s.inspect} is missing"
    when :file_missing
      datas.empty? and raise ComplexConfig::ConfigurationFileMissing,
        "configuration file #{pathname.to_s.inspect} is missing"
    end
    results = datas.map { |d| evaluate(pathname, d) }
    hashes =
      if ::Psych::VERSION < "4"
        results.map { |r| ::YAML.load(r, pathname) }
      else
        results.map { |r| ::YAML.unsafe_load(r, filename: pathname) }
      end
    settings = ComplexConfig::Settings.build(name, hashes.shift)
    hashes.each { |h| settings.attributes_update(h) }
    if shared = settings.shared?
      shared = shared.to_h
      settings.each do |key, value|
        if value.is_a? ComplexConfig::Settings
          value.attributes_update_if_nil(shared)
        elsif value.nil?
          settings[key] = ComplexConfig::Settings.build(nil, shared.dup)
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
      ks = provide_key_source(config_pathname, encrypt)
      File.secure_write(config_pathname + '.enc') do |out|
        out.write ComplexConfig::Encryption.new(ks.key_bytes).encrypt(prepare_output(value))
      end
      if store_key
        File.secure_write(config_pathname + '.key') do |out|
          out.write ks.key
        end
      end
      ks.key
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
  rescue ComplexConfig::ConfigurationFileMissing, ComplexConfig::EncryptionKeyMissing
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

  if RUBY_VERSION >= "3"
    def evaluate(pathname, data)
      erb = ::ERB.new(data, trim_mode: '-')
      erb.filename = pathname.to_s
      erb.result
    end
  else
    def evaluate(pathname, data)
      erb = ::ERB.new(data, nil, '-')
      erb.filename = pathname.to_s
      erb.result
    end
  end

  def env
    @env || defined?(Rails) && Rails.respond_to?(:env) && Rails.env ||
      ENV['RAILS_ENV'] ||
      'development'
  end

  attr_writer :env

  def key_source(pathname = nil)
    [
      ComplexConfig::KeySource.new(var: @key),
      ComplexConfig::KeySource.new(pathname: pathname),
      ComplexConfig::KeySource.new(env_var: 'COMPLEX_CONFIG_KEY'),
      ComplexConfig::KeySource.new(env_var: 'RAILS_MASTER_KEY'),
      ComplexConfig::KeySource.new(master_key_pathname: master_key_pathname),
    ].find(&:key)
  end

  def key(pathname = nil)
    key_source(pathname).ask_and_send(:key)
  end

  attr_writer :key

  attr_writer :master_key_pathname

  def new_key
    SecureRandom.hex(16)
  end

  def valid_key?(key)
    ks = ComplexConfig::KeySource.new(var: key)
    ComplexConfig::Encryption.new(ks.key_bytes)
    ks
  rescue
    false
  end

  private

  def decrypt_config_case(pathname)
    enc_pathname = pathname.to_s + '.enc'
    my_ks        = key_source(pathname)
    if File.exist?(enc_pathname)
      if my_ks.ask_and_send(:key)
        text = IO.binread(enc_pathname)
        decrypted = ComplexConfig::Encryption.new(my_ks.key_bytes).decrypt(text)
        return decrypted, :ok, enc_pathname
      else
        return nil, :key_missing, enc_pathname
      end
    end
    return nil, :file_missing, enc_pathname
  end

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

  def provide_key_source(pathname, encrypt)
    ks =
      case encrypt
      when :random
        ComplexConfig::KeySource.new(var: new_key)
      when true
        key_source(pathname)
      when String
        if encrypt =~ /\A\h{32}\z/
          ComplexConfig::KeySource.new(var: encrypt)
        else
          raise ComplexConfig::EncryptionKeyInvalid,
            "encryption key has wrong format, has to be hex number of length "\
            "32, was #{encrypt.inspect}"
        end
      end
    ks or raise ComplexConfig::EncryptionKeyInvalid, "encryption key is missing"
  end
end

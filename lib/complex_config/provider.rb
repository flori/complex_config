require 'set'
require 'erb'
require 'pathname'
require 'yaml'
require 'mize'
require 'tins/xt/secure_write'
require 'tins/xt/ask_and_send'

# A provider class that manages configuration loading, caching, and access
#
# The Provider class serves as the central hub for accessing and managing
# configuration data within the ComplexConfig system. It handles loading
# configuration files from disk, applying environment-specific settings,
# processing plugins for dynamic attribute resolution, and providing memoized
# access to configuration data through caching mechanisms.
#
# @see ComplexConfig::Config
# @see ComplexConfig::Settings
# @see ComplexConfig::Proxy
# @see ComplexConfig::KeySource
# @see ComplexConfig::Encryption
class ComplexConfig::Provider
  include Tins::SexySingleton
  include ComplexConfig::Provider::Shortcuts

  # Initializes a new provider instance with default settings
  #
  # Sets up the provider with an empty plugins collection and enables deep
  # freezing by default to ensure configuration immutability.
  def initialize
    @plugins     = Set.new
    @deep_freeze = true
  end

  # The master_key_pathname= method sets the pathname for the master encryption
  # key file
  #
  # This setter method allows configuring the location of the master key file
  # that will be used for encryption and decryption operations throughout the
  # system
  #
  # @attr_writer [String, nil] pathname The path to the master key file, or nil to reset
  attr_writer :master_key_pathname

  # The master_key_pathname method retrieves the configured master key file
  # path
  #
  # This method returns the explicitly set master key pathname if one has been
  # configured, otherwise it defaults to a 'master.key' file within the
  # configuration directory
  #
  # @return [String, Pathname] the path to the master key file or a Pathname object
  #   representing the default location in the config directory
  def master_key_pathname
    if @master_key_pathname
      @master_key_pathname
    else
      config_dir + 'master.key'
    end
  end

  # The configure_with method applies the given configuration to this provider
  # instance
  #
  # This method takes a configuration object and applies its settings to the
  # current provider instance It then flushes the configuration cache to ensure
  # the changes take effect immediately
  #
  # @param config [ComplexConfig::Config] the configuration object to apply to
  #   this provider
  # @return [self] returns self for chaining operations
  def configure_with(config)
    config.configure(self)
    flush_cache
  end

  # The plugins attribute reader provides access to the set of plugins
  # registered with this provider
  #
  # @return [Set<Proc>] the set containing all registered plugin procs
  attr_reader :plugins

  # The add_plugin method adds a new plugin to the provider's collection of
  # plugins
  #
  # This method registers a plugin proc with the provider, allowing it to be
  # executed when configuration attributes are accessed and no direct value is
  # found
  #
  # @param plugin [Proc] The plugin proc to add to the provider's plugins set
  # @return [self] Returns self to allow for method chaining
  def add_plugin(plugin)
    plugins.add plugin
    self
  end

  # The deep_freeze= method sets the deep freezing behavior for configuration
  # objects
  #
  # This method configures whether configuration settings should be deeply
  # frozen to prevent modification after initialization. When disabling deep
  # freezing, it clears the configuration cache to ensure changes take effect
  # immediately.
  #
  # @attr_writer [Boolean] flag true to enable deep freezing, false to disable it
  def deep_freeze=(flag)
    if @deep_freeze && !flag
      mize_cache_clear
    end
    @deep_freeze = flag
  end

  # The deep_freeze? method checks whether deep freezing is enabled for
  # configuration objects
  #
  # This method returns a boolean value indicating whether the provider has
  # been configured to deeply freeze configuration settings, preventing
  # modification after initialization
  #
  # @return [TrueClass, FalseClass] true if deep freezing is enabled, false
  #   otherwise
  def deep_freeze?
    !!@deep_freeze
  end

  # The apply_plugins method executes registered plugins for a given setting
  # and ID
  #
  # This method iterates through all registered plugins and attempts to execute
  # each one with the provided setting and ID. It uses catch/throw to handle
  # plugin skipping behavior, returning the first non-skipped plugin result.
  #
  # @param setting [ComplexConfig::Settings] The settings object to apply
  #   plugins to
  # @param id [Object] The identifier used when executing plugins
  # @return [Object, nil] The result from the first applicable plugin, or nil
  #   if no plugin applies
  def apply_plugins(setting, id)
    plugins.find do |plugin|
      catch :skip do
        value = setting.instance_exec(id, &plugin) and return value
      end
      nil
    end
  end

  # The config_dir= method sets the configuration directory path for the
  # provider
  #
  # This setter method assigns a new configuration directory path to the
  # provider instance, allowing it to locate configuration files at the
  # specified location
  #
  # @attr_writer [String, nil] dir The path to the configuration directory, or nil to
  #   reset to default
  def config_dir=(dir)
    if dir.nil?
      @config_dir = nil
    else
      @config_dir = Pathname.new(dir)
    end
  end

  # The config_dir method retrieves the configuration directory path
  #
  # This method returns the configured configuration directory path, falling
  # back to a default location based on Rails root or the current working
  # directory when no explicit path is set
  #
  # @return [Pathname] the configuration directory path
  def config_dir
    @config_dir || (defined?(Rails) && Rails.respond_to?(:root) && Rails.root || Pathname.pwd) + 'config'
  end

  # The pathname method constructs a file path for a configuration file
  #
  # This method takes a configuration name and returns the full path to the
  # corresponding YAML configuration file by combining the configuration
  # directory with the name and file extension.
  #
  # @param name [String] the name of the configuration file (without extension)
  # @return [Pathname] the full path to the configuration file with .yml extension
  def pathname(name)
    config_dir + "#{name}.yml"
  end

  # The decrypt_config method retrieves decrypted configuration data from an
  # encrypted file
  #
  # @param pathname [String, Pathname] the path to the encrypted configuration
  #   file
  #
  # @return [String, nil] the decrypted configuration content if successful, or
  #   nil if decryption fails
  #
  # @see decrypt_config_case for the internal implementation that handles the
  #   actual decryption logic
  def decrypt_config(pathname)
    decrypt_config_case(pathname).first
  end

  # The encrypt_config method encrypts configuration data using a key source
  #
  # @param pathname [String, Pathname] the path to the configuration file to be
  #   encrypted
  # @param config [Object] the configuration object to encrypt
  # @return [String] the base64-encoded encrypted string including the
  #   encrypted data, initialization vector, and authentication tag separated by
  #   '--'
  def encrypt_config(pathname, config)
    ks = key_source(pathname)
    ComplexConfig::Encryption.new(ks.key_bytes).encrypt(config)
  end

  # The config method reads and processes configuration data from a file
  #
  # This method loads configuration data from the specified file path, handling
  # both plain YAML files and encrypted YAML files. It processes the
  # configuration data through ERB evaluation, parses it into Ruby objects, and
  # builds a Settings object with appropriate environment-specific values.
  #
  # @param pathname [String, Pathname] The path to the configuration file to read
  # @param name [String, nil] The name to use when building the Settings object,
  #   or nil to derive it from the filename
  # @return [ComplexConfig::Settings] A Settings object containing the parsed
  #   configuration data with environment-specific values
  # @raise [ComplexConfig::ConfigurationFileMissing] If the configuration file
  #   cannot be found and no decrypted data is available
  # @raise [ComplexConfig::EncryptionKeyMissing] If an encrypted configuration
  #   file is encountered but no encryption key is available
  # @raise [ComplexConfig::ConfigurationSyntaxError] If the YAML syntax in the
  #   configuration file is invalid
  # @raise [TypeError] If the configuration data cannot be converted to a hash
  # @see decrypt_config_case for decryption logic
  # @see evaluate for ERB processing
  # @see ComplexConfig::Settings.build for Settings object construction
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

  # The [] method provides access to configuration data by name
  #
  # This method serves as a shortcut for retrieving configuration settings by
  # their name, delegating to the config method with the appropriate pathname
  # and name parameters
  #
  # @param name [String] the name of the configuration to retrieve
  # @return [ComplexConfig::Settings] the configuration settings object for the
  #   specified name
  def [](name)
    config pathname(name), name
  end
  memoize method: :[]

  # The write_config method writes configuration data to a file
  #
  # This method handles writing configuration data to either a plain YAML file
  # or an encrypted file depending on the encryption settings. It supports
  # storing encryption keys alongside the encrypted configuration file and
  # provides options for specifying the encryption key source.
  #
  # @param name [String, ComplexConfig::Settings] The name of the configuration
  #   to write or a Settings object
  # @param value [Object, nil] The configuration value to write, required when
  #   name is a string
  # @param encrypt [Boolean, Symbol, String] Whether to encrypt the
  #   configuration, accepts :random, true, or a hex key string
  # @param store_key [Boolean] Whether to store the encryption key in a
  #   separate file
  #
  # @return [String, Boolean] The encryption key if stored, otherwise true
  # @see prepare_output for data formatting
  # @see provide_key_source for key management
  # @see flush_cache to clear the configuration cache after writing
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

  # The prepare_output method converts a value into YAML format
  #
  # This method takes a value and transforms it into a YAML string
  # representation by first converting it to a hash with string keys and then
  # serializing it as YAML
  #
  # @param value [Object] the value to convert to YAML format
  # @return [String] the YAML representation of the value
  def prepare_output(value)
    value.each_with_object({}) do |(k, v), h|
      h[k.to_s] = v
    end.to_yaml
  end

  # The exist? method checks whether a configuration file exists and is
  # accessible
  #
  # @param name [String] the name of the configuration to check for existence
  # @return [TrueClass, FalseClass] true if the configuration file exists and
  #   can be loaded, false otherwise
  # @see config for the underlying configuration loading logic
  # @see ComplexConfig::ConfigurationFileMissing when a configuration file is missing
  # @see ComplexConfig::EncryptionKeyMissing when an encryption key is required but not available
  def exist?(name)
    !!config(pathname(name), name)
  rescue ComplexConfig::ConfigurationFileMissing, ComplexConfig::EncryptionKeyMissing
    false
  end

  # The proxy method creates and returns a new proxy object for dynamic
  # configuration access
  #
  # This method instantiates a ComplexConfig::Proxy object that defers
  # configuration loading until a method is first called. The proxy supports
  # environment-specific configuration lookups and can handle both direct
  # configuration access and existence checks.
  #
  # @param env [String, nil] The environment name to use for configuration lookups,
  #   defaults to nil which will use the default environment
  # @return [ComplexConfig::Proxy] A new proxy object for dynamic configuration
  #   access
  def proxy(env = nil)
    ComplexConfig::Proxy.new(env)
  end
  memoize method: :proxy

  # The flush_cache method clears the configuration cache and returns the
  # receiver
  #
  # This method invalidates the cached configuration data stored in the
  # provider, ensuring that subsequent configuration accesses will reload the
  # data from source. It is typically used during development when
  # configuration files may have changed or when explicit cache invalidation is
  # required.
  #
  # @return [ComplexConfig::Provider] the provider instance itself for chaining operations
  def flush_cache
    mize_cache_clear
    self
  end

  if RUBY_VERSION >= "3"
    # The evaluate method processes ERB template data and returns the result
    #
    # This method takes raw configuration data that may contain ERB templating
    # syntax and evaluates it using Ruby's built-in ERB processor. It sets up
    # the ERB environment with appropriate trim mode and filename for proper
    # error reporting before executing the template.
    #
    # @param pathname [String, Pathname] The path to the file being evaluated,
    #   used for error reporting and debugging purposes
    # @param data [String] The raw configuration data string that may contain
    #   ERB templating syntax to be processed
    # @return [String] The processed configuration data with all ERB templates
    #   evaluated and replaced with their actual values
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

  # The env method retrieves the current environment name for configuration
  # lookups
  #
  # This method determines the appropriate environment to use for configuration
  # access by checking various possible sources in order: an explicitly set
  # instance variable, Rails environment if available, the RAILS_ENV
  # environment variable, or falling back to 'development' as the default
  #
  # @return [String] the name of the current environment
  def env
    @env || defined?(Rails) && Rails.respond_to?(:env) && Rails.env ||
      ENV['RAILS_ENV'] ||
      'development'
  end

  # The env= method sets the environment name for configuration lookups
  #
  # This setter method assigns a new environment value to the provider
  # instance, which will be used when accessing configuration data that
  # supports environment-specific values.
  #
  # @attr_writer [String, nil] env The environment name to use for configuration
  #   lookups, or nil to reset to the default environment
  attr_writer :env

  # The key_source method retrieves an encryption key from configured sources
  #
  # This method attempts to find a valid encryption key by checking multiple
  # possible sources in a specific order until one provides a usable key. It
  # prioritizes keys from instance variables, file paths, environment
  # variables, and master key files.
  #
  # @param pathname [String, nil] The path to a configuration file that may
  #   contain a key
  # @return [ComplexConfig::KeySource, nil] A KeySource object containing the
  #   first valid key found, or nil if no key is available
  def key_source(pathname = nil)
    [
      ComplexConfig::KeySource.new(var: @key),
      ComplexConfig::KeySource.new(pathname: pathname),
      ComplexConfig::KeySource.new(env_var: 'COMPLEX_CONFIG_KEY'),
      ComplexConfig::KeySource.new(env_var: 'RAILS_MASTER_KEY'),
      ComplexConfig::KeySource.new(master_key_pathname: master_key_pathname),
    ].find(&:key)
  end

  # The key method retrieves an encryption key from configured sources
  #
  # This method obtains an encryption key by delegating to the key_source
  # method with the provided pathname, then extracts the actual key value from
  # the returned KeySource object
  #
  # @param pathname [String, nil] The path to a configuration file that may
  #   contain a key
  # @return [String, nil] The encryption key as a string if found, or nil if no
  #   key is available
  def key(pathname = nil)
    key_source(pathname).ask_and_send(:key)
  end

  # The key= method sets the encryption key for the provider
  #
  # This setter method assigns a new encryption key value to the provider
  # instance, which will be used for encrypting and decrypting configuration
  # data.
  #
  # @attr_writer [String, nil] key The encryption key to use, or nil to clear the key
  attr_writer :key

  # The new_key method generates a random encryption key
  #
  # This method creates a secure random key suitable for encryption purposes by
  # generating a hexadecimal string of 32 characters (16 bytes).
  #
  # @return [String] a randomly generated hexadecimal encryption key
  def new_key
    SecureRandom.hex(16)
  end

  # The valid_key? method checks whether a given key is valid for encryption
  # purposes
  #
  # This method attempts to validate an encryption key by creating a KeySource
  # object with the provided key and then trying to instantiate an Encryption
  # object with it to verify the key's format and validity
  #
  # @param key [String] the encryption key to validate
  # @return [ComplexConfig::KeySource, FalseClass] returns the KeySource object
  #   if the key is valid, false otherwise
  def valid_key?(key)
    ks = ComplexConfig::KeySource.new(var: key)
    ComplexConfig::Encryption.new(ks.key_bytes)
    ks
  rescue
    false
  end

  private

  # The decrypt_config_case method handles the decryption of encrypted
  # configuration files
  #
  # This method checks for the existence of an encrypted configuration file and
  # attempts to decrypt it using the available key source. It returns different
  # status codes based on whether the decryption was successful, if a key was
  # missing, or if the file itself was missing.
  #
  # @param pathname [String, Pathname] The path to the configuration file to
  #   check for encryption
  #
  # @return [Array] An array containing the decrypted data (or nil), a symbol
  #   indicating the result status (:ok, :key_missing, or :file_missing), and
  #   the encrypted file's pathname
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

  # The interpret_name_value method processes name and value parameters for
  # configuration handling
  #
  # This method normalizes the input parameters for configuration operations by
  # validating the name parameter type and preparing the value parameter
  # accordingly. It handles different input scenarios including
  # ComplexConfig::Settings objects and string/symbol names.
  #
  # @param name [String, Symbol, ComplexConfig::Settings] The name parameter
  #   which can be a string, symbol, or ComplexConfig::Settings object
  # @param value [Object, nil] The value parameter to be processed, typically a
  #   hash or nil
  #
  # @return [Array<String, Object>] An array containing the normalized name and
  #   value parameters for further configuration processing
  #
  # @raise [ArgumentError] if the name parameter is not a string/symbol or
  #   ComplexConfig::Settings object
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

  # The provide_key_source method determines and returns an appropriate key
  # source for encryption operations
  #
  # This method analyzes the encryption parameter and constructs a suitable key
  # source object based on whether a random key should be generated, an
  # existing key source should be used, or a specific hex key string was
  # provided
  #
  # @param pathname [String, nil] The path to a configuration file that may
  #   contain a key
  # @param encrypt [Boolean, Symbol, String] Encryption directive that
  #   determines key source selection
  # @return [ComplexConfig::KeySource] A key source object configured with the
  #   appropriate encryption key
  # @raise [ComplexConfig::EncryptionKeyInvalid] if the encryption key is
  #   missing or has invalid format
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

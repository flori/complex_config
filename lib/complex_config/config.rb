module ComplexConfig
  # Configuration class for setting up ComplexConfig behavior
  #
  # This class provides a structured way to configure the ComplexConfig system,
  # including environment settings, deep freezing behavior, and plugin registration.
  #
  # @example Basic configuration
  #   ComplexConfig.configure do |config|
  #     config.deep_freeze = false
  #     config.env = 'production'
  #   end
  #
  # @example Adding custom plugins
  #   ComplexConfig.configure do |config|
  #     config.add_plugin -> id do
  #       if base64_string = ask_and_send("#{id}_base64")
  #         Base64.decode64(base64_string)
  #       else
  #         skip
  #       end
  #     end
  #   end
  class Config < Struct.new(:config_dir, :env, :deep_freeze, :plugins)
    # Initializes a new configuration instance
    def initialize(*)
      super
      self.plugins = []
    end

    # Applies the configuration to a provider
    #
    # This method sets all configuration attributes on the provider and
    # registers any plugins. It's called internally by ComplexConfig.configure.
    #
    # @param provider [ComplexConfig::Provider] The provider to configure
    # @return [self] Returns self for chaining
    def configure(provider)
      each_pair do |name, value|
        value.nil? and next
        name == :plugins and next
        provider.__send__("#{name}=", value)
      end
      plugins.each do |code|
        provider.add_plugin(code)
      end
      self
    end

    # Adds a plugin to the configuration
    #
    # Plugins are lambda expressions that can provide custom behavior for
    # configuration attributes.
    #
    # @param code [Proc] The plugin code to add
    # @return [self] Returns self for chaining
    def add_plugin(code)
      plugins << code
      self
    end
  end

  # Configures the ComplexConfig system with the provided settings
  #
  # This is the main entry point for configuring ComplexConfig. It creates a
  # configuration object, yields it to the provided block for customization,
  # and applies the configuration to the provider.
  #
  # @yield [config] Yields the configuration object for setup
  # @yieldparam config [Config] The configuration object to modify
  # @return [Config] The configured object
  def self.configure
    config = Config.new
    yield config
    ComplexConfig::Provider.configure_with config
    config
  end
end

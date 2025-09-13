class ComplexConfig::Provider
  # A module that provides convenient shortcuts for accessing configuration
  # data
  #
  # This module defines methods that create proxy objects for easy
  # configuration access with lazy evaluation and environment-specific lookups.
  # It's designed to be included in classes that need quick access to
  # configuration settings without explicit environment handling.
  #
  # @see ComplexConfig::Provider::Shortcuts
  module Shortcuts
    # The complex_config_with_env method provides access to configuration data
    # with explicit environment targeting.
    #
    # @param name [String, nil] The name of the configuration to access, or nil
    # to return a proxy object
    #
    # @param env [String] The environment name to use for configuration
    # lookups, defaults to the current provider environment
    #
    # @return [ComplexConfig::Settings, ComplexConfig::Proxy] Returns either
    # the configuration settings for the specified name and environment, or a
    # proxy object if no name is provided
    def complex_config_with_env(name = nil, env = ComplexConfig::Provider.env)
      if name
        ComplexConfig::Provider[name][env.to_s]
      else
        ComplexConfig::Provider.proxy(env.to_s)
      end
    end

    # Alias for {complex_config_with_env}
    # Provides a shorter syntax for accessing configuration with environment
    # targeting.
    #
    # @see complex_config_with_env
    alias cc complex_config_with_env

    # The complex_config method provides access to configuration data with
    # optional name parameter.
    #
    # @param name [String, nil] The name of the configuration to access, or nil
    # to return a proxy object
    # @return [ComplexConfig::Settings, ComplexConfig::Proxy] Returns either
    # the configuration settings for the specified name, or a proxy object if
    # no name is provided
    def complex_config(name = nil)
      if name
        ComplexConfig::Provider[name]
      else
        ComplexConfig::Provider.proxy
      end
    end
  end
end

module ComplexConfig
  # A proxy class that provides dynamic configuration access with lazy
  # evaluation
  #
  # The Proxy class acts as a wrapper around configuration access, deferring
  # the actual configuration loading until a method is first called. It
  # supports environment-specific configuration lookups and can handle both
  # direct configuration access and existence checks.
  #
  # @attr_reader [String, nil] env The environment name used for configuration
  # lookups
  class Proxy < BasicObject
    # The proxy object's initialization method sets up the environment for
    # configuration access.
    #
    # @param env [String, nil] The environment name to use for configuration
    #   lookups, defaults to nil which will use the default environment
    def initialize(env = nil)
      @env = env
    end

    # The to_s method returns a string representation of the proxy object.
    #
    # @return [String] the string 'ComplexConfig::Proxy'
    def to_s
      'ComplexConfig::Proxy'
    end

    # The inspect method returns a string representation of the proxy object.
    #
    # @return [String] a string representation in the format "#<ComplexConfig::Proxy>"
    def inspect
      "#<#{to_s}>"
    end

    # The reload method flushes the configuration cache and returns the
    # receiver.
    #
    # @return [ComplexConfig::Proxy] the proxy object itself
    def reload
      ::ComplexConfig::Provider.flush_cache
      self
    end

    # The method_missing method handles dynamic configuration access and
    # validation.
    #
    # @param name [Symbol] The name of the method being called
    # @param args [Array] Arguments passed to the method
    #
    # @return [Object] The result of the dynamic configuration lookup or method call
    def method_missing(name, *args)
      if name =~ /\?\z/
        method_name, name = name, $`
        exist = ::ComplexConfig::Provider.exist?(name)
        (class << self; self; end).class_eval do
          define_method(method_name) do |env = nil|
            if exist
              __send__(name, *args)
            else
              nil
            end
          end
        end
        __send__(method_name, *args)
      else
        config = ::ComplexConfig::Provider[name]
        (class << self; self; end).class_eval do
          define_method(name) do |env = nil|
            if env ||= @env
              config[env] || ::ComplexConfig::Settings.new
            else
              config
            end
          end
        end
        __send__(name, *args)
      end
    end
  end
end

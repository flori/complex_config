module ComplexConfig
  class Proxy < BasicObject
    def initialize(env = nil)
      @env = env
    end

    def to_s
      'ComplexConfig::Proxy'
    end

    def inspect
      "#<#{to_s}>"
    end

    def reload
      ::ComplexConfig::Provider.flush_cache
      self
    end

    def method_missing(name, *args)
      config = ::ComplexConfig::Provider[name]
      env, = args
      if env
        config[env]
      elsif @env
        config[@env]
      else
        config
      end
    end
  end
end

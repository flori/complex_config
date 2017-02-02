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
            if env
              config[env]
            elsif @env
              config[@env]
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

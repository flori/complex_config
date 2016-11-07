class ComplexConfig::Provider
  module Shortcuts
    def complex_config_with_env(name = nil, env = ComplexConfig::Provider.env)
      if name
        ComplexConfig::Provider[name][env.to_s]
      else
        ComplexConfig::Provider.proxy(env.to_s)
      end
    end

    alias cc complex_config_with_env

    def complex_config(name = nil)
      if name
        ComplexConfig::Provider[name]
      else
        ComplexConfig::Provider.proxy
      end
    end
  end
end

require 'complex_config'

def complex_config_with_env(name, env = ComplexConfig::Provider.env)
  ComplexConfig::Provider[name][env.to_s]
end
alias cc complex_config_with_env

def complex_config(name)
  ComplexConfig::Provider[name]
end

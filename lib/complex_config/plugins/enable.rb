require 'complex_config'
require 'complex_config/plugins'

ComplexConfig::Provider.add_plugin ComplexConfig::Plugins::MONEY
ComplexConfig::Provider.add_plugin ComplexConfig::Plugins::URI

require 'tins'

# Main namespace module for the ComplexConfig library
#
# This module serves as the root namespace for all components of the
# ComplexConfig system, providing configuration management, encryption
# capabilities, and structured access to YAML-based configuration data with
# support for environment-specific settings and plugin-based attribute
# resolution.
#
# @see ComplexConfig::Config
# @see ComplexConfig::Provider
# @see ComplexConfig::Settings
# @see ComplexConfig::Encryption
# @see ComplexConfig::KeySource
module ComplexConfig
end

require 'complex_config/version'
require 'complex_config/errors'
require 'complex_config/proxy'
require 'complex_config/tree'
require 'complex_config/settings'
require 'complex_config/config'
require 'complex_config/key_source'
require 'complex_config/provider/shortcuts'
require 'complex_config/provider'
require 'complex_config/encryption'
defined? Rails and require 'complex_config/railtie'

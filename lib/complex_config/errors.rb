module ComplexConfig

  # Abstract base class for ComplexConfig exceptions
  #
  # This class serves as the root of the exception hierarchy for the
  # ComplexConfig library. All custom exceptions raised by ComplexConfig should
  # inherit from this class.
  #
  # @abstract
  class ComplexConfigError < StandardError
    # Wraps an exception with a custom error class from the ComplexConfig
    # hierarchy
    #
    # This method takes an exception and wraps it with a new error class that
    # is derived from the ComplexConfig error hierarchy. It allows for more
    # specific error handling by converting one type of exception into another
    # while preserving the original message and backtrace.
    #
    # @param klass [Class, String] The error class to wrap the exception with,
    #   either as a Class object or a string name that can be resolved via
    #   ComplexConfig.const_get
    # @param e [StandardError] The original exception to be wrapped
    # @return [ComplexConfig::ComplexConfigError] A new instance of the specified
    #   error class containing the original exception's message and backtrace
    def self.wrap(klass, e)
      Class === klass or klass = ComplexConfig.const_get(klass)
      error = klass.new(e.message)
      error.set_backtrace(e.backtrace)
      error
    end
  end

  # An exception raised when an expected configuration attribute is missing
  #
  # This error is triggered when code attempts to access a configuration
  # attribute that has not been defined or set within the configuration system.
  # It inherits from ComplexConfigError, making it part of the library's
  # standardized exception hierarchy for consistent error handling.
  #
  # @see ComplexConfigError
  class AttributeMissing < ComplexConfigError
  end

  # An exception raised when a required configuration file is missing
  #
  # This error is triggered when the system attempts to access a configuration
  # file that cannot be found at the expected location. It inherits from
  # ComplexConfigError, making it part of the library's standardized exception
  # hierarchy for consistent error handling.
  #
  # @see ComplexConfigError
  # @see ComplexConfig::Provider#config
  # @see ComplexConfig::Provider#decrypt_config_case
  class ConfigurationFileMissing < ComplexConfigError
  end

  # An exception raised when a configuration file has invalid syntax
  #
  # This error is triggered when the system encounters YAML syntax errors in
  # configuration files that prevent them from being properly parsed. It
  # inherits from ComplexConfigError, making it part of the library's
  # standardized exception hierarchy for consistent error handling.
  #
  # @see ComplexConfigError
  # @see ComplexConfig::Provider#config
  # @see ComplexConfig::Provider#decrypt_config_case
  class ConfigurationSyntaxError < ComplexConfigError
  end

  # An abstract base class for encryption-related errors in the ComplexConfig
  # library.
  #
  # This class serves as the root of the encryption exception hierarchy,
  # providing a common base for all encryption-specific exceptions raised by
  # ComplexConfig.
  #
  # @abstract
  # @see ComplexConfigError
  class EncryptionError < ComplexConfigError
  end

  # An exception raised when an encryption key has an invalid format or length
  #
  # This error is triggered when an encryption key does not meet the required
  # specifications, such as having an incorrect byte length. It inherits from
  # EncryptionError, making it part of the library's standardized exception
  # hierarchy for consistent error handling.
  #
  # @see EncryptionError
  # @see ComplexConfig::Encryption
  class EncryptionKeyInvalid < EncryptionError
  end

  # An exception raised when a required encryption key is missing
  #
  # This error is triggered when the system attempts to access an encryption key
  # that cannot be found through any of the configured sources. It inherits from
  # EncryptionError, making it part of the library's standardized exception
  # hierarchy for consistent error handling.

  # @see EncryptionError
  # @see ComplexConfig::Encryption
  # @see ComplexConfig::KeySource
  class EncryptionKeyMissing < EncryptionError
  end

  # An exception raised when decryption operations fail
  #
  # This error is triggered when the system encounters issues during the
  # decryption process, such as invalid authentication tags or cipher errors
  # that prevent successful decryption. It inherits from EncryptionError,
  # making it part of the library's standardized exception hierarchy for
  # consistent error handling.
  #
  # @see EncryptionError
  # @see ComplexConfig::Encryption#decrypt
  class DecryptionFailed < EncryptionError
  end
end

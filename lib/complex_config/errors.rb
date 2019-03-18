module ComplexConfig
  class ComplexConfigError < StandardError
    def self.wrap(klass, e)
      Class === klass or klass = ComplexConfig.const_get(klass)
      error = klass.new(e.message)
      error.set_backtrace(e.backtrace)
      error
    end
  end

  class AttributeMissing < ComplexConfigError
  end

  class ConfigurationFileMissing < ComplexConfigError
  end

  class ConfigurationSyntaxError < ComplexConfigError
  end

  class EncryptionError < ComplexConfigError
  end

  class EncryptionKeyInvalid < EncryptionError
  end

  class EncryptionKeyMissing < EncryptionError
  end

  class DecryptionFailed < EncryptionError
  end
end

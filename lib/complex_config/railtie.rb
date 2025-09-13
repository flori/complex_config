module ComplexConfig
  # Rails integration for ComplexConfig
  #
  # Provides integration with Rails application lifecycle by flushing the
  # configuration cache during the to_prepare callback, ensuring that
  # configuration changes are picked up correctly in development mode.
  class Railtie < Rails::Railtie
    config.to_prepare do
      ComplexConfig::Provider.flush_cache
    end
  end
end

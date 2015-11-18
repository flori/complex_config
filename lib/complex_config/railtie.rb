module ComplexConfig
  class Railtie < Rails::Railtie
    config.to_prepare do
      ComplexConfig::Provider.flush_cache
    end
  end
end

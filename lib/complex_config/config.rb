module ComplexConfig
  Config = Struct.new('Config', :config_dir, :env, :deep_freeze, :plugins) do
    def initialize(*)
      super
      self.plugins = []
    end

    def configure(provider)
      each_pair do |name, value|
        value.nil? and next
        name == :plugins and next
        provider.__send__("#{name}=", value)
      end
      plugins.each do |code|
        provider.add_plugin(code)
      end
      self
    end

    def add_plugin(code)
      plugins << code
      self
    end
  end

  def self.configure
    config = Config.new
    yield config
    ComplexConfig::Provider.configure_with config
    config
  end
end

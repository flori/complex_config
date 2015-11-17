require 'spec_helper'

RSpec.describe ComplexConfig::Provider do
  let :provider do
    ComplexConfig::Provider
  end

  after do
    provider.flush_cache
  end

  context 'plugin' do
    let :plugin do
      -> id { __send__ id }
    end

    let :setting do
      double('Setting')
    end

    before do
      provider.plugins.clear
    end

    it 'can add one' do
      expect { provider.add_plugin plugin }.to change { provider.plugins.size }.by(1)
    end

    it 'can apply plugins' do
      provider.add_plugin plugin
      expect(setting).to receive(:foo).and_return :bar
      expect(provider.apply_plugins(setting, :foo)).to eq :bar
    end
  end

  context 'pathnames' do
    module ::Rails
      def self.root
      end unless respond_to?(:root)
    end

    after do
      provider.root = nil
    end

    it 'can compute default pathname' do
      provider.root = Pathname.new('bar')
      expect(provider.pathname('foo')).to eq Pathname.new('bar/config/foo.yml')
    end

    it 'can derive rails root from Rails.root if present' do
      dir = Pathname.new('bar')
      expect(Rails).to receive(:root).and_return(dir)
      expect(provider.root).to eq dir
    end

    it 'falls back to current working directory by default' do
      expect(provider.root).to eq Pathname.pwd
    end
  end

  context 'reading configurations' do
    it 'can read a configuration file' do
      expect(
        provider.config(asset('config.yml'))
      ).to be_a ComplexConfig::Settings
    end

    it 'has deep frozen settings' do
      settings = provider.config(asset('config.yml'))
      expect(settings).to be_frozen
    end

    it 'deep freezing can be disabled' do
      begin
        provider.deep_freeze = false
        settings = provider.config(asset('config.yml'))
        expect(settings).not_to be_frozen
      ensure
        provider.deep_freeze = true
      end
    end

    it 'handles missing configuration files' do
      expect { provider.config(asset('nix_config.yml')) }.to\
        raise_error(ComplexConfig::ConfigurationFileMissing)
    end

    it 'handles syntax errors in configuration files' do
      expect { provider.config(asset('broken_config.yml')) }.to\
        raise_error(ComplexConfig::ConfigurationSyntaxError)
    end
  end

  context 'handling configuration files with []' do
    before do
      provider.root = Pathname.new(__FILE__).dirname.dirname
    end

    it 'returns the correct configuration' do
      expect(provider['config']).to be_a ComplexConfig::Settings
    end

    it 'caches the configuration after first use' do
      expect {
        expect(provider['config']).to be_a ComplexConfig::Settings
      }.to change {
        provider.instance.__send__(:__memoize_cache__).size
      }.by(1)
      expect(provider).not_to receive(:config)
      expect(provider['config']).to be_a ComplexConfig::Settings
    end

    it 'can flush loaded configurations' do
      expect(provider['config']).to be_a ComplexConfig::Settings
      result = nil
      expect {
        result = provider.flush_cache
      }.to change {
        provider.instance.__send__(:__memoize_cache__).size
      }.by(-1)
      expect(result).to be_a ComplexConfig::Provider
    end
  end

  context 'evaluating configuration files with ERB' do
    it 'evaluates a config file correctly' do
      expect(
        provider.config(asset('config.yml')).development.config.pi
      ).to be_within(1e-6).of Math::PI
    end
  end

  context 'environment' do
    module ::Rails
      def self.env
      end unless respond_to?(:env)
    end

    after do
      provider.env = nil
    end

    it 'can be set manually' do
      provider.env = 'foobar'
      expect(provider.env).to eq 'foobar'
    end

    it 'can derive environments from Rails.env if present' do
      expect(Rails).to receive(:env).and_return('foobar')
      expect(provider.env).to eq 'foobar'
    end

    it 'falls back to "development" as a default' do
      expect(provider.env).to eq 'development'
    end
  end
end

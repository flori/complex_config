require 'spec_helper'
require 'fileutils'

RSpec.describe ComplexConfig::Provider do
  let :provider do
    ComplexConfig::Provider
  end

  reset_new_config = -> * {
    provider.config_dir = Pathname.new(__FILE__).dirname.dirname + 'config'
    provider.key = nil
    ENV['COMPLEX_CONFIG_KEY'] = nil
    ENV['RAILS_MASTER_KEY'] = nil
    FileUtils.rm_f(provider.config_dir + 'new_config.yml')
    FileUtils.rm_f(provider.config_dir + 'new_config.yml.enc')
    FileUtils.rm_f(provider.config_dir + 'new_config.yml.key')
  }

  after do
    instance_eval(&reset_new_config)
    provider.flush_cache
  end

  context 'plugin' do
    let :plugin do
      -> id {
        if id == :evaluate_plugin
          :evaluated
        else
          skip
        end
      }
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
      allow(setting).to receive(:skip).and_throw :skip
      expect(provider.apply_plugins(setting, :evaluate_plugin)).to eq :evaluated
    end
  end

  context 'pathnames' do
    before do
      module ::Rails
        def self.root
        end
      end
      provider.config_dir = nil
    end

    it 'can derive rails root from Rails.root if present' do
      allow(::Rails).to receive(:root).and_return Pathname.new('bar')
      dir = Pathname.new('bar/config')
      expect(provider.config_dir).to eq dir
    end

    it 'falls back to current working directory by default' do
      expect(provider.config_dir).to eq Pathname.pwd + 'config'
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

  context 'writing configurations' do
    before do
      provider.config_dir = Pathname.new(__FILE__).dirname.dirname + 'config'
    end

    let :config do
      provider.config(asset('config.yml'))
    end

    it 'can be written' do
      provider.write_config('new_config', value: config)
      expect(provider.config(asset('new_config.yml'))).to eq config
    end

    it 'can be changed and written' do
      provider.deep_freeze = false
      config.development.config.baz = 'something else'
      provider.write_config('new_config', value: config)
      expect(provider.config(asset('new_config.yml')).development.config.baz).to eq 'something else'
    end
  end

  context 'reading encrypted configurations' do
    before do
      provider.config_dir = Pathname.new(__FILE__).dirname.dirname + 'config'
    end

    let :key do
      IO.binread(provider.config_dir + 'with-key-file.yml.key')
    end

    it 'can read when key is set by accessor' do
      provider.key = key
      expect(provider['without-key-file'].development.foo.bar).to eq 'baz'
    end

    it 'can read when key is in ENV var' do
      ENV['RAILS_MASTER_KEY'] = key
      expect(provider['without-key-file'].development.foo.bar).to eq 'baz'
      ENV['RAILS_MASTER_KEY'] = nil
    end

    it 'can read when key is stored in file' do
      expect(provider['with-key-file'].development.foo.bar).to eq 'baz'
    end
  end

  context 'writing encrypted configurations' do
    before do
      provider.config_dir = Pathname.new(__FILE__).dirname.dirname + 'config'
      instance_eval(&reset_new_config)
    end

    let :config do
      provider.config(asset('config.yml'))
    end

    it 'can be written with random key' do
      key = provider.write_config('new_config', value: config, encrypt: :random, store_key: false)
      provider.key = key
      expect(provider.config(asset('new_config.yml'))).to eq config
    end

    it 'can be written with random key and store key' do
      provider.write_config('new_config', value: config, encrypt: :random, store_key: true)
      expect(provider.config(asset('new_config.yml'))).to eq config
    end

    it 'can be written with passed key' do
      key = SecureRandom.hex(16)
      provider.write_config('new_config', value: config, encrypt: key)
      provider.key = key
      expect(provider.config(asset('new_config.yml'))).to eq config
    end

    it 'can be written with configured key' do
      provider.write_config('new_config', value: config)
      expect(provider.config(asset('new_config.yml'))).to eq config
    end

    it 'can be written with COMPLEX_CONFIG_KEY key' do
      ENV['COMPLEX_CONFIG_KEY'] = SecureRandom.hex(16)
      k = provider.write_config('new_config', value: config, encrypt: true)
      expect(k).to eq ENV['COMPLEX_CONFIG_KEY']
      expect(provider.config(asset('new_config.yml'))).to eq config
    end

    it 'can be written with RAILS_MASTER_KEY key' do
      ENV['RAILS_MASTER_KEY'] = SecureRandom.hex(16)
      k = provider.write_config('new_config', value: config, encrypt: true)
      expect(k).to eq ENV['RAILS_MASTER_KEY']
      expect(provider.config(asset('new_config.yml'))).to eq config
    end

    it 'can be changed and written' do
      provider.deep_freeze = false
      expect(provider.config(asset('config.yml')).development.config.baz).to eq 'something'
      config.development.config.baz = 'something else'
      provider.write_config('new_config', value: config)
      expect(provider.config(asset('new_config.yml')).development.config.baz).to eq 'something else'
      #
      new_config = provider.config(asset('new_config.yml'), :new_config)
      new_config.development.config.baz = 'something else else'
      provider.write_config new_config
      expect(provider.config(asset('new_config.yml')).development.config.baz).to eq 'something else else'
      #
      new_config = provider.config(asset('new_config.yml'), :new_config)
      provider.write_config(new_config, value: { development: { config: { baz: 'even more else' } } })
      #expect(provider.config(asset('new_config.yml')).development.config.baz).to eq 'something else else'
    end
  end

  context 'handling configuration files with []' do
    before do
      provider.config_dir = Pathname.new(__FILE__).dirname.dirname + 'config'
    end

    it 'returns the correct configuration' do
      expect(provider['config']).to be_a ComplexConfig::Settings
    end

    it 'caches the configuration after first use' do
      expect {
        expect(provider['config']).to be_a ComplexConfig::Settings
      }.to change {
        provider.instance.__send__(:__mize_cache__).__send__(:size)
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
        provider.instance.__send__(:__mize_cache__).__send__(:size)
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

    before do
      allow(ENV).to receive(:[]).with('RAILS_ENV').and_return('development')
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

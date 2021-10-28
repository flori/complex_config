require 'spec_helper'
require 'fileutils'

RSpec.describe ComplexConfig::Provider do
  reset_new_config = -> * {
    described_class.config_dir = Pathname.new(__FILE__).dirname.dirname + 'config'
    described_class.key = nil
    ENV['COMPLEX_CONFIG_KEY'] = nil
    ENV['RAILS_MASTER_KEY'] = nil
    FileUtils.rm_f(described_class.config_dir + 'new_config.yml')
    FileUtils.rm_f(described_class.config_dir + 'new_config.yml.enc')
    FileUtils.rm_f(described_class.config_dir + 'new_config.yml.key')
  }

  after do
    instance_eval(&reset_new_config)
    described_class.flush_cache
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
      described_class.plugins.clear
    end

    it 'can add one' do
      expect { described_class.add_plugin plugin }.to change { described_class.plugins.size }.by(1)
    end

    it 'can apply plugins' do
      described_class.add_plugin plugin
      allow(setting).to receive(:skip).and_throw :skip
      expect(described_class.apply_plugins(setting, :evaluate_plugin)).to eq :evaluated
    end
  end

  context 'pathnames' do
    before do
      module ::Rails
        def self.root
        end
      end
      described_class.config_dir = nil
    end

    it 'can derive rails root from Rails.root if present' do
      allow(::Rails).to receive(:root).and_return Pathname.new('bar')
      dir = Pathname.new('bar/config')
      expect(described_class.config_dir).to eq dir
    end

    it 'falls back to current working directory by default' do
      expect(described_class.config_dir).to eq Pathname.pwd + 'config'
    end

    it 'can derive master_key_pathname' do
      expect(described_class.master_key_pathname).to eq\
      Pathname.pwd.join('config/master.key')
    end

    it 'can set master_key_pathname' do
      described_class.master_key_pathname = 'foo'
      expect(described_class.master_key_pathname).to eq 'foo'
    end
  end

  context 'reading configurations' do
    it 'can read a configuration file' do
      expect(
        described_class.config(asset('config.yml'))
      ).to be_a ComplexConfig::Settings
    end

    it 'has deep frozen settings' do
      settings = described_class.config(asset('config.yml'))
      expect(settings).to be_frozen
    end

    it 'deep freezing can be disabled' do
      begin
        described_class.deep_freeze = false
        settings = described_class.config(asset('config.yml'))
        expect(settings).not_to be_frozen
      ensure
        described_class.deep_freeze = true
      end
    end

    it 'handles missing configuration files' do
      expect { described_class.config(asset('nix_config.yml')) }.to\
        raise_error(ComplexConfig::ConfigurationFileMissing)
    end

    it 'handles syntax errors in configuration files' do
      expect { described_class.config(asset('broken_config.yml')) }.to\
        raise_error(ComplexConfig::ConfigurationSyntaxError)
    end
  end

  context 'writing configurations' do
    before do
      described_class.config_dir = Pathname.new(__FILE__).dirname.dirname + 'config'
    end

    let :config do
      described_class.config(asset('config.yml'))
    end

    it 'can be written' do
      described_class.write_config('new_config', value: config)
      expect(described_class.config(asset('new_config.yml'))).to eq config
    end

    it 'can be changed and written' do
      described_class.deep_freeze = false
      config.development.config.baz = 'something else'
      described_class.write_config('new_config', value: config)
      expect(described_class.config(asset('new_config.yml')).development.config.baz).to eq 'something else'
    end
  end

  context 'reading encrypted configurations' do
    before do
      described_class.config_dir = Pathname.new(__FILE__).dirname.dirname + 'config'
    end

    let :key do
      IO.binread(described_class.config_dir + 'with-key-file.yml.key')
    end

    it 'can read when key is set by accessor' do
      described_class.key = key
      expect(described_class.key).to eq key.chomp
      expect(described_class['without-key-file'].development.foo.bar).to eq 'baz'
    end

    it 'can read when key is in ENV var' do
      ENV['RAILS_MASTER_KEY'] = key
      expect(described_class['without-key-file'].development.foo.bar).to eq 'baz'
      ENV['RAILS_MASTER_KEY'] = nil
    end

    it 'can read when key is stored in file' do
      expect(described_class['with-key-file'].development.foo.bar).to eq 'baz'
    end

    it 'can check the size of a given key' do
      expect(described_class).to be_valid_key(key)
      expect(described_class).not_to be_valid_key(key + ' blub')
    end
  end

  context 'writing encrypted configurations' do
    before do
      described_class.config_dir = Pathname.new(__FILE__).dirname.dirname + 'config'
      instance_eval(&reset_new_config)
    end

    let :config do
      described_class.config(asset('config.yml'))
    end

    it 'can be written with random key' do
      key = described_class.write_config('new_config', value: config, encrypt: :random, store_key: false)
      described_class.key = key
      expect(described_class.config(asset('new_config.yml'))).to eq config
    end

    it 'can be written with random key and store key' do
      described_class.write_config('new_config', value: config, encrypt: :random, store_key: true)
      expect(described_class.config(asset('new_config.yml'))).to eq config
    end

    it 'can be written with passed key' do
      key = SecureRandom.hex(16)
      described_class.write_config('new_config', value: config, encrypt: key)
      described_class.key = key
      expect(described_class.config(asset('new_config.yml'))).to eq config
    end

    it 'can be written with configured key' do
      described_class.write_config('new_config', value: config)
      expect(described_class.config(asset('new_config.yml'))).to eq config
    end

    it 'can be written with COMPLEX_CONFIG_KEY key' do
      ENV['COMPLEX_CONFIG_KEY'] = SecureRandom.hex(16)
      k = described_class.write_config('new_config', value: config, encrypt: true)
      expect(k).to eq ENV['COMPLEX_CONFIG_KEY']
      expect(described_class.config(asset('new_config.yml'))).to eq config
    end

    it 'can be written with RAILS_MASTER_KEY key' do
      ENV['RAILS_MASTER_KEY'] = SecureRandom.hex(16)
      k = described_class.write_config('new_config', value: config, encrypt: true)
      expect(k).to eq ENV['RAILS_MASTER_KEY']
      expect(described_class.config(asset('new_config.yml'))).to eq config
    end

    it 'can encrypt file content with RAILS_MASTER_KEY key' do
      ENV['RAILS_MASTER_KEY'] = SecureRandom.hex(16)
      encrypted = described_class.encrypt_config(asset('new_config.yml'), 'test')
      expect(encrypted).not_to be_empty
      ks = ComplexConfig::KeySource.new(env_var: 'RAILS_MASTER_KEY')
      expect(
        ComplexConfig::Encryption.new(ks.key_bytes).decrypt(encrypted)
      ).to eq 'test'
    end

    it 'can be changed and written' do
      described_class.deep_freeze = false
      expect(described_class.config(asset('config.yml')).development.config.baz).to eq 'something'
      config.development.config.baz = 'something else'
      described_class.write_config('new_config', value: config)
      expect(described_class.config(asset('new_config.yml')).development.config.baz).to eq 'something else'
      #
      new_config = described_class.config(asset('new_config.yml'), :new_config)
      new_config.development.config.baz = 'something else else'
      described_class.write_config new_config
      expect(described_class.config(asset('new_config.yml')).development.config.baz).to eq 'something else else'
      #
      new_config = described_class.config(asset('new_config.yml'), :new_config)
      described_class.write_config(new_config, value: { development: { config: { baz: 'even more else' } } })
      #expect(described_class.config(asset('new_config.yml')).development.config.baz).to eq 'something else else'
    end
  end

  context 'handling configuration files with []' do
    before do
      described_class.config_dir = Pathname.new(__FILE__).dirname.dirname + 'config'
    end

    it 'returns the correct configuration' do
      expect(described_class['config']).to be_a ComplexConfig::Settings
    end

    it 'caches the configuration after first use' do
      expect {
        expect(described_class['config']).to be_a ComplexConfig::Settings
      }.to change {
        described_class.instance.__send__(:__mize_cache__).instance_variable_get(:@data).size
      }.by(1)
      expect(described_class).not_to receive(:config)
      expect(described_class['config']).to be_a ComplexConfig::Settings
    end

    it 'can flush loaded configurations' do
      expect(described_class['config']).to be_a ComplexConfig::Settings
      result = nil
      expect {
        result = described_class.flush_cache
      }.to change {
        described_class.instance.__send__(:__mize_cache__).instance_variable_get(:@data).size
      }.by(-1)
      expect(result).to be_a described_class
    end
  end

  context 'handling configuration files with aliases (considered unsafe)' do
    before do
      described_class.config_dir = Pathname.new(__FILE__) + '../../config'
    end

    it 'reads yaml files with aliases just fine' do
      expect(
        described_class.config(asset('config_with_alias.yml')).specific.extended
      ).to be true
    end
  end

  context 'evaluating configuration files with ERB' do
    it 'evaluates a config file correctly' do
      expect(
        described_class.config(asset('config.yml')).development.config.pi
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
      described_class.env = nil
    end

    it 'can be set manually' do
      described_class.env = 'foobar'
      expect(described_class.env).to eq 'foobar'
    end

    it 'can derive environments from Rails.env if present' do
      expect(Rails).to receive(:env).and_return('foobar')
      expect(described_class.env).to eq 'foobar'
    end

    it 'falls back to "development" as a default' do
      expect(described_class.env).to eq 'development'
    end

  end

  context 'shared' do
    before do
      described_class.config_dir = Pathname.new(__FILE__).dirname.dirname + 'config'
    end

    it 'can share values' do
      expect(described_class['config'].development.shared).to eq true
      expect(described_class['config'].test.shared).to eq nil
      expect(described_class['config'].staging.shared).to eq false
    end
  end
end

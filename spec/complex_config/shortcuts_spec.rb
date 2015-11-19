require 'spec_helper'
require 'complex_config/shortcuts'

RSpec.describe 'shortcuts' do
  let :provider do
    ComplexConfig::Provider
  end

  before do
    provider.config_dir = Pathname.new(__FILE__).dirname.dirname + 'config'
  end

  it 'returns a proxy object for the shortcuts' do
    expect(complex_config_with_env.to_s).to eq 'ComplexConfig::Proxy'
    expect(cc.inspect).to eq '#<ComplexConfig::Proxy>'
    expect(complex_config.to_s).to eq 'ComplexConfig::Proxy'
    expect(cc.config.name_prefix).to eq :config
  end

  it 'can be reloaded via shortcut' do
    expect(ComplexConfig::Provider).to receive(:flush_cache)
    complex_config.reload
  end

  it 'has the complex_config_with_env "shortcut"' do
    settings = complex_config_with_env.config('development')
    expect(settings).to be_a ComplexConfig::Settings
    expect(settings.config.baz).to eq 'something'
    settings = complex_config_with_env.config('test')
    expect(settings).to be_a ComplexConfig::Settings
    expect(settings.config.baz).to eq 'something else'
  end

  it 'has the alias cc for complex_config_with_env' do
    settings = cc.config(:development)
    expect(settings).to be_a ComplexConfig::Settings
    expect(settings.config.baz).to eq 'something'
  end

  it 'considers the environment for complex_config_with_env' do
    settings = complex_config_with_env.config
    expect(settings).to be_a ComplexConfig::Settings
    expect(settings.config.baz).to eq 'something'
    allow(provider).to receive(:env).and_return('test')
    settings = complex_config_with_env.config
    expect(settings).to be_a ComplexConfig::Settings
    expect(settings.config.baz).to eq 'something else'
  end

  it 'has the complex_config shortcut' do
    settings = complex_config.config
    expect(settings).to be_a ComplexConfig::Settings
    expect(settings.development.config.baz).to eq 'something'
    expect(settings.test.config.baz).to eq 'something else'
  end

  it 'has alternatives instead of method syntax' do
    settings = complex_config_with_env(:config, :development)
    expect(settings).to be_a ComplexConfig::Settings
    settings = cc(:config)
    expect(settings).to be_a ComplexConfig::Settings
    settings = complex_config(:config)
    expect(settings).to be_a ComplexConfig::Settings
  end
end

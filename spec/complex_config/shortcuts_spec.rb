require 'spec_helper'
require 'complex_config/shortcuts'

RSpec.describe 'shortcuts' do
  let :provider do
    ComplexConfig::Provider
  end

  before do
    provider.root = Pathname.new(__FILE__).dirname.dirname
  end

  it 'has the complex_config_with_env "shortcut"' do
    settings = complex_config_with_env('config', 'development')
    expect(settings).to be_a ComplexConfig::Settings
    expect(settings.config.baz).to eq 'something'
    settings = complex_config_with_env('config', 'test')
    expect(settings).to be_a ComplexConfig::Settings
    expect(settings.config.baz).to eq 'something else'
  end

  it 'has the alias cc for complex_config_with_env' do
    settings = cc(:config, :development)
    expect(settings).to be_a ComplexConfig::Settings
    expect(settings.config.baz).to eq 'something'
  end

  it 'considers the environment for complex_config_with_env' do
    settings = complex_config_with_env('config')
    expect(settings).to be_a ComplexConfig::Settings
    expect(settings.config.baz).to eq 'something'
    allow(provider).to receive(:env).and_return('test')
    settings = complex_config_with_env('config')
    expect(settings).to be_a ComplexConfig::Settings
    expect(settings.config.baz).to eq 'something else'
  end

  it 'has the complex_config shortcut' do
    settings = complex_config(:config)
    expect(settings).to be_a ComplexConfig::Settings
    expect(settings.development.config.baz).to eq 'something'
    expect(settings.test.config.baz).to eq 'something else'
  end
end

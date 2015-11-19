require 'spec_helper'

RSpec.describe ComplexConfig::Config do
  let :plugin_code do
    -> id { skip }
  end

  it 'configures' do
    ComplexConfig.configure do |config|
      config.config_dir = 'foo'
      config.env        = 'bar'
      config.add_plugin plugin_code
    end
    expect(ComplexConfig::Provider.config_dir).to eq Pathname.new('foo')
    expect(ComplexConfig::Provider.env).to eq 'bar'
    expect(ComplexConfig::Provider.plugins).to include plugin_code
  end
end


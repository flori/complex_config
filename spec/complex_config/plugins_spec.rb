require 'spec_helper'
require 'complex_config/plugins/enable'

RSpec.describe ComplexConfig::Settings do
  let :provider do
    ComplexConfig::Provider
  end

  let :settings do
    ComplexConfig::Settings[
      foo: {
        test_url:      'http://www.ping.de',
        cash_in_cents: 100.to_money.cents
      }
    ]
  end

  context ComplexConfig::Plugins::URI do
    it 'can return an URL string' do
      expect(settings.foo.test_url).to eq 'http://www.ping.de'
    end

    it 'can return an URI' do
      expect(settings.foo.test_uri).to eq URI.parse('http://www.ping.de')
    end

    it 'can skips if blub' do
      expect { settings.foo.nix_uri }.to raise_error(ComplexConfig::AttributeMissing)
    end
  end

  context ComplexConfig::Plugins::MONEY do
    it 'can return a Fixnum' do
      expect(settings.foo.cash_in_cents).to eq 100_00
    end

    it 'can return a Money instance' do
      expect(settings.foo.cash).to eq 100.to_money
    end
  end
end


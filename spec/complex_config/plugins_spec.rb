require 'spec_helper'
require 'complex_config/plugins/enable'

describe ComplexConfig::Plugins do
  let :provider do
    ComplexConfig::Provider
  end

  context 'with EUR default' do
    let :settings do
      ComplexConfig::Settings[
        foo: {
          test_url:      'http://www.ping.de',
          cash_in_cents: 100.to_money('EUR').cents
        }
      ]
    end

    around do |example|
      old = ENV['COMPLEX_CONFIG_MONEY_DEFAULT_CURRENCY']
      ENV.delete('COMPLEX_CONFIG_MONEY_DEFAULT_CURRENCY')
      example.run
    ensure
      ENV['COMPLEX_CONFIG_MONEY_DEFAULT_CURRENCY'] = old
    end

    context described_class::URI do
      it 'can return an URL string' do
        expect(settings.foo.test_url).to eq 'http://www.ping.de'
      end

      it 'can return an URI' do
        expect(settings.foo.test_uri).to eq URI.parse('http://www.ping.de')
      end

      it 'can return an URI' do
        expect(settings.foo[:test_uri]).to eq URI.parse('http://www.ping.de')
      end

      it 'can skips if blub' do
        expect { settings.foo.nix_uri }.to raise_error(ComplexConfig::AttributeMissing)
      end
    end

    context described_class::MONEY do
      it 'can return a Fixnum' do
        expect(settings.foo.cash_in_cents).to eq 100_00
      end

      it 'can return a Money instance' do
        expect(settings.foo.cash).to eq 100.to_money('EUR')
      end
    end
  end

  context 'with BTC' do
    let :settings do
      ComplexConfig::Settings[
        foo: {
          test_url:      'http://www.ping.de',
          cash_in_cents: 100.to_money('BTC').cents
        }
      ]
    end

    around do |example|
      old, ENV['COMPLEX_CONFIG_MONEY_DEFAULT_CURRENCY'] = ENV['COMPLEX_CONFIG_MONEY_DEFAULT_CURRENCY'], 'BTC'
      example.run
    ensure
      ENV['COMPLEX_CONFIG_MONEY_DEFAULT_CURRENCY'] = old
    end
    it 'can return a Money instance' do
      expect(settings.foo.cash).to eq 100.to_money('BTC')
    end
  end
end

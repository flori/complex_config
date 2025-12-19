begin
  require 'monetize'
rescue LoadError
  if $DEBUG
    warn 'Cannot load runtime dependency "monetize":"\
    " Skipping plugin ComplexConfig::Plugins::MONEY.'
  end
else
  module ComplexConfig::Plugins
    MONEY = -> id do
      currency = ENV.fetch('COMPLEX_CONFIG_MONEY_DEFAULT_CURRENCY', 'EUR')
      if cents = ask_and_send("#{id}_in_cents")
        Money.from_cents(cents, currency.upcase)
      else
        skip
      end
    end
  end

  ComplexConfig::Provider.add_plugin ComplexConfig::Plugins::MONEY
end

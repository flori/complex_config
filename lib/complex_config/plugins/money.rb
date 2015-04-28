begin
  require 'forwardable' # XXX monetize forgets to require this
  require 'monetize'
rescue LoadError
  if $DEBUG
    warn 'Cannot load runtime dependency "monetize":"\
    " Skipping plugin ComplexConfig::Plugins::MONEY.'
  end
else
  module ComplexConfig::Plugins
    MONEY = -> id do
      if cents = ask_and_send("#{id}_in_cents")
        Money.new(cents)
      else
        skip
      end
    end
  end

  ComplexConfig::Provider.add_plugin ComplexConfig::Plugins::MONEY
end

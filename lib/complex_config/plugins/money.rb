require 'monetize'

module ComplexConfig::Plugins
  MONEY = -> id do
    if cents = ask_and_send("#{id}_in_cents")
      Money.new(cents)
    else
      skip
    end
  end
end

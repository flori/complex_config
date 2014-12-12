require 'uri'

module ComplexConfig::Plugins
  URI = -> id do
    if url = id.to_s.sub(/uri\z/, 'url') and url = ask_and_send(url)
      ::URI.parse(url)
    else
      skip
    end
  end
end


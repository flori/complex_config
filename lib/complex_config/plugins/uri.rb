require 'uri'

module ComplexConfig::Plugins
  URI = -> id do
    url = id.to_s.dup
    if url.sub!(/uri\z/, 'url') and url = ask_and_send(url)
      ::URI.parse(url)
    else
      skip
    end
  end
end

ComplexConfig::Provider.add_plugin ComplexConfig::Plugins::URI

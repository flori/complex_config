# ComplexConfig

## Description

This library makes your YAML configuration files available via a nice API. It
also supports different configurations for each `RAILS_ENV` environment and
using plugins to return more complex settings values.

## Installation

You can use rubygems to fetch the gem and install it for you:

    # gem install complex_config

You can also put this line into your Gemfile

    gem 'complex_config', require: 'complex_config/rude'

and bundle. This command will enable all the default plugins and make the `cc`
and `complex_config` shortcuts available.

## Usage

Given a config file like this and named `config/products.yml`

    evelopment:
      flux_capacitor:
        version_20:
          name: Flux Capacitor Version 2.0
          price_in_cents: 12_000_00
          manual_pdf_url: "http://brown-inc.com/manuals/fc_20.pdf"
        pro_version:
          name: Flux Capacitor Professional
          price_in_cents: 23_000_00
          manual_pdf_url: "http://brown-inc.com/manuals/fc_pro.pdf"
        enterprise_version:
          name: Flux Capacitor Enterpise
          price_in_cents: 1_600_000_00
          manual_pdf_url: "http://brown-inc.com/manuals/fc_enterprise.pdf"

    test:
      flux_capacitor:
        test_version:
          name: Yadayada
          price_in_cents: 6_66
          manual_pdf_url: "http://staging.brown-inc.com/manuals/fc_10.pdf"

and using `require "complex_config/rude"` in the `"development"` environment you
can now access the configuration.

### Accessing configuration settings

Fetching the name of a product:

    > cc(:products).flux_capacitor.enterprise_version.name => "Flux Capacitor Enterpise"

Fetching the price of a product in cents:

    > cc(:products).flux_capacitor.enterprise_version.price_in_cents => 160000000

Fetching the price of a product and using the ComplexConfig::Plugins::MONEY
plugin to format it:

    > cc(:products).flux_capacitor.enterprise_version.price.format => "€1,600,000.00"

Fetching the URL of a product manual as a string:

    > cc(:products).flux_capacitor.enterprise_version.manual_pdf_url => "http://brown-inc.com/manuals/fc_enterprise.pdf"

Fetching the URL of a product manual and using the ComplexConfig::Plugins::URI
plugin return an URI instance:

    > cc(:products).flux_capacitor.enterprise_version.manual_pdf_uri => #<URI::HTTP:0x007ff626d2a2e8 URL:http://brown-inc.com/manuals/fc_enterprise.pdf>

You can also fetch config settings from a different environment:

    > cc(:products, :test).flux_capacitor => ---
    :test_version:
      :name: Yadayada
      :price_in_cents: 666
      :manual_pdf_url: http://staging.brown-inc.com/manuals/fc_10.pdf

Calling `complex_config(:products)` instead of `cc(…)` would skip the implicite
namespacing via the `RAILS_ENV` environment, so
`complex_config(:products).test.flux_capacitor` returns the same settings
object.

### Adding plugins

You can add your own plugins by calling

    ComplexConfig::Provider.add_plugin SomeNamespace::PLUGIN

### Implementing your own plugins

A plugin is just a lambda expression with a single argument `id` which
identifies the attribute that is being accessed. If it calls `skip` it won't
apply and the following plugins are tried until one doesn't call `skip` and
returns a value instead.

Here is the `ComplexConfig::Plugins::MONEY` plugin for example:

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

## Changes

* 2015-01-27 Release 0.2.0
  * Fix for attributes named like Enumerable methods
  * Make tests run on JRuby
* 2015-01-01 Release 0.1.1
  * Some small fixes for handling of arrays
* 2014-12-15 Release 0.1.0
  * Freeze configuration by default.

* 2014-12-12 Release 0.0.0

## Download

The homepage of this library is located at

* https://github.com/flori/complex_config

## Author

[Florian Frank](mailto:flori@ping.de)

## License

This software is licensed under the Apache 2.0 license.

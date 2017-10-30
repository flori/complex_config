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
and `complex_config` shortcuts available. The configurations are expected to be
in the `config` subdirectory according to the rails convention.

## Usage

Given a config file like this and named `config/products.yml`

    development:
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

    > cc.products.flux_capacitor.enterprise_version.name => "Flux Capacitor Enterpise"

If the name of configuration file isn't valid ruby method name syntax you can also
use `cc(:products).flux_capacitor…` to avoid this problem.

Fetching the price of a product in cents:

    > cc.products.flux_capacitor.enterprise_version.price_in_cents => 160000000

Fetching the price of a product and using the ComplexConfig::Plugins::MONEY
plugin to format it:

    > cc.products.flux_capacitor.enterprise_version.price.format => "€1,600,000.00"

Fetching the URL of a product manual as a string:

    > cc.products.flux_capacitor.enterprise_version.manual_pdf_url => "http://brown-inc.com/manuals/fc_enterprise.pdf"

Fetching the URL of a product manual and using the ComplexConfig::Plugins::URI
plugin return an URI instance:

    > cc.products.flux_capacitor.enterprise_version.manual_pdf_uri => #<URI::HTTP:0x007ff626d2a2e8 URL:http://brown-inc.com/manuals/fc_enterprise.pdf>

You can also fetch config settings from a different environment:

    >> pp cc.products(:test); nil
    products.flux_capacitor.test_version.name = "Yadayada"
    products.flux_capacitor.test_version.price_in_cents = 666
    products.flux_capacitor.test_version.manual_pdf_url = "http://staging.brown-inc.com/manuals/fc_10.pdf"

Calling `complex_config.products.` instead of `cc(…)` would skip the implicite
namespacing via the `RAILS_ENV` environment, so
`complex_config(:products).test.flux_capacitor` returns the same settings
object.

### Configuration

You can complex\_config by passing a block to its configure method, which you
can for example do in a rails config/initializers file:

    ComplexConfig.configure do |config|
      config.deep_freeze = !Rails.env.test? # allow modification during tests b/c of stubs etc.
      
      # config.env = 'some_environment'

      # config.config_dir = Rails.root + 'config'

      config.add_plugin -> id do
        if base64_string = ask_and_send("#{id}_base64")
          Base64.decode64 base64_string
        else
          skip
        end
      end
    end

### Adding plugins

You can add your own plugins by calling

    ComplexConfig::Provider.add_plugin SomeNamespace::PLUGIN

or in the configuration block by calling

    ComplexConfig.configure do |config|
      config.add_plugin SomeNamespace::PLUGIN
    end

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
* 2017-10-30 Release 0.11.2
  * Small bugfix
* 2017-10-27 Release 0.11.1
  * Small bugfix
* 2017-10-27 Release 0.11.0
  * Support encrypted config files a la rails
* 2017-02-02 Release 0.10.0
  * `cc.foo?`/`complex_config.foo?` returns config or nil (when not existant)
* 2017-01-23 Release 0.9.2
  * Improve performance for proxy objects
* 2016-11-22 Release 0.9.1
  * Fix travis builds
* 2016-11-22 Release 0.9.0
  * Extract ComplexConfig::Provider::Shortcuts into its own module
* 2016-07-21 Release 0.8.0
  * `ComplexConfig::Settings` can be replaced with `replace_attributes` which
    allows for easier testing by calling:
    `cc.foo.replace_attributes(new: 'settings')`.
* 2016-07-15 Release 0.7.0
  * Slim down `ComplexConfig::Settings` interface to avoid clashes with methods
    mixed into `Object` class or `Enumerable#instance_methods`
* 2016-07-15 Release 0.6.0
  * Depend on mize gem for caching.
* 2016-06-23 Release 0.5.2
  * Resolve index access via the plugin code path, so foo.bar and foo[:bar]
    have the same result for a plugin key.
* 2015-11-19 Release 0.5.0
  * Support rails reloading behaviour.
  * Allow configuration via ComplexConfig.configure(&block) method.
* 2015-11-17 Release 0.4.0
  * Add root object for configuration, e. g. cc.name instead of cc(name).
* 2015-11-03 Release 0.3.1
  * Add missing dependency to tins.
* 2015-11-03 Release 0.3.0
  * Add nicer default output for settings.
* 2015-03-24 Release 0.2.3
  * Fix typo in load error case of money.
* 2015-02-25 Release 0.2.2
  * Fix an issue with path interpolation.
* 2015-01-28 Release 0.2.1
  * Turn monetize into a runtime dependency for the plugin.
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

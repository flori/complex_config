# -*- encoding: utf-8 -*-
# stub: complex_config 0.14.1 ruby lib

Gem::Specification.new do |s|
  s.name = "complex_config".freeze
  s.version = "0.14.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "2018-12-07"
  s.description = "This library allows you to access configuration files via a simple interface".freeze
  s.email = "flori@ping.de".freeze
  s.executables = ["complex_config".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/complex_config.rb".freeze, "lib/complex_config/config.rb".freeze, "lib/complex_config/encryption.rb".freeze, "lib/complex_config/errors.rb".freeze, "lib/complex_config/key_source.rb".freeze, "lib/complex_config/plugins.rb".freeze, "lib/complex_config/plugins/enable.rb".freeze, "lib/complex_config/plugins/money.rb".freeze, "lib/complex_config/plugins/uri.rb".freeze, "lib/complex_config/provider.rb".freeze, "lib/complex_config/provider/shortcuts.rb".freeze, "lib/complex_config/proxy.rb".freeze, "lib/complex_config/railtie.rb".freeze, "lib/complex_config/rude.rb".freeze, "lib/complex_config/settings.rb".freeze, "lib/complex_config/shortcuts.rb".freeze, "lib/complex_config/version.rb".freeze]
  s.files = [".gitignore".freeze, ".rspec".freeze, ".travis.yml".freeze, ".utilsrc".freeze, "COPYING".freeze, "Gemfile".freeze, "README.md".freeze, "Rakefile".freeze, "VERSION".freeze, "bin/complex_config".freeze, "complex_config.gemspec".freeze, "config/products.yml".freeze, "lib/complex_config.rb".freeze, "lib/complex_config/config.rb".freeze, "lib/complex_config/encryption.rb".freeze, "lib/complex_config/errors.rb".freeze, "lib/complex_config/key_source.rb".freeze, "lib/complex_config/plugins.rb".freeze, "lib/complex_config/plugins/enable.rb".freeze, "lib/complex_config/plugins/money.rb".freeze, "lib/complex_config/plugins/uri.rb".freeze, "lib/complex_config/provider.rb".freeze, "lib/complex_config/provider/shortcuts.rb".freeze, "lib/complex_config/proxy.rb".freeze, "lib/complex_config/railtie.rb".freeze, "lib/complex_config/rude.rb".freeze, "lib/complex_config/settings.rb".freeze, "lib/complex_config/shortcuts.rb".freeze, "lib/complex_config/version.rb".freeze, "spec/complex_config/config_spec.rb".freeze, "spec/complex_config/encryption_spec.rb".freeze, "spec/complex_config/key_source_spec.rb".freeze, "spec/complex_config/plugins_spec.rb".freeze, "spec/complex_config/provider_spec.rb".freeze, "spec/complex_config/settings_spec.rb".freeze, "spec/complex_config/shortcuts_spec.rb".freeze, "spec/config/broken_config.yml".freeze, "spec/config/config.yml".freeze, "spec/config/master.key".freeze, "spec/config/with-key-file.yml.enc".freeze, "spec/config/with-key-file.yml.key".freeze, "spec/config/without-key-file.yml.enc".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://github.com/flori/complex_config".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rdoc_options = ["--title".freeze, "ComplexConfig -- configuration library".freeze, "--main".freeze, "README.md".freeze]
  s.rubygems_version = "2.7.8".freeze
  s.summary = "configuration library".freeze
  s.test_files = ["spec/complex_config/config_spec.rb".freeze, "spec/complex_config/encryption_spec.rb".freeze, "spec/complex_config/key_source_spec.rb".freeze, "spec/complex_config/plugins_spec.rb".freeze, "spec/complex_config/provider_spec.rb".freeze, "spec/complex_config/settings_spec.rb".freeze, "spec/complex_config/shortcuts_spec.rb".freeze, "spec/spec_helper.rb".freeze]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<monetize>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<json>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<tins>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<mize>.freeze, ["~> 0.3", ">= 0.3.4"])
    else
      s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<monetize>.freeze, [">= 0"])
      s.add_dependency(%q<json>.freeze, [">= 0"])
      s.add_dependency(%q<tins>.freeze, [">= 0"])
      s.add_dependency(%q<mize>.freeze, ["~> 0.3", ">= 0.3.4"])
    end
  else
    s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<monetize>.freeze, [">= 0"])
    s.add_dependency(%q<json>.freeze, [">= 0"])
    s.add_dependency(%q<tins>.freeze, [">= 0"])
    s.add_dependency(%q<mize>.freeze, ["~> 0.3", ">= 0.3.4"])
  end
end

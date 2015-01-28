# -*- encoding: utf-8 -*-
# stub: complex_config 0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "complex_config"
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Florian Frank"]
  s.date = "2015-01-28"
  s.description = "This library allows you to access configuration files via a simple interface"
  s.email = "flori@ping.de"
  s.extra_rdoc_files = ["README.md", "lib/complex_config.rb", "lib/complex_config/errors.rb", "lib/complex_config/plugins.rb", "lib/complex_config/plugins/enable.rb", "lib/complex_config/plugins/money.rb", "lib/complex_config/plugins/uri.rb", "lib/complex_config/provider.rb", "lib/complex_config/rude.rb", "lib/complex_config/settings.rb", "lib/complex_config/shortcuts.rb", "lib/complex_config/version.rb"]
  s.files = [".gitignore", ".rspec", ".travis.yml", ".utilsrc", "COPYING", "Gemfile", "README.md", "Rakefile", "TODO.md", "VERSION", "complex_config.gemspec", "lib/complex_config.rb", "lib/complex_config/errors.rb", "lib/complex_config/plugins.rb", "lib/complex_config/plugins/enable.rb", "lib/complex_config/plugins/money.rb", "lib/complex_config/plugins/uri.rb", "lib/complex_config/provider.rb", "lib/complex_config/rude.rb", "lib/complex_config/settings.rb", "lib/complex_config/shortcuts.rb", "lib/complex_config/version.rb", "spec/complex_config/plugins_spec.rb", "spec/complex_config/provider_spec.rb", "spec/complex_config/settings_spec.rb", "spec/complex_config/shortcuts_spec.rb", "spec/config/broken_config.yml", "spec/config/config.yml", "spec/spec_helper.rb"]
  s.homepage = "https://github.com/flori/complex_config"
  s.licenses = ["Apache-2.0"]
  s.rdoc_options = ["--title", "ComplexConfig -- configuration library", "--main", "README.md"]
  s.rubygems_version = "2.4.5"
  s.summary = "configuration library"
  s.test_files = ["spec/complex_config/plugins_spec.rb", "spec/complex_config/provider_spec.rb", "spec/complex_config/settings_spec.rb", "spec/complex_config/shortcuts_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>, ["~> 1.0.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
    else
      s.add_dependency(%q<gem_hadar>, ["~> 1.0.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
    end
  else
    s.add_dependency(%q<gem_hadar>, ["~> 1.0.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
  end
end

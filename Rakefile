# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'complex_config'
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "https://github.com/flori/#{name}"
  summary     'configuration library'
  description 'This library allows you to access configuration files via a simple interface'
  test_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage', '.rvmrc', '.AppleDouble', '.DS_Store'
  readme      'README.md'
  title       "#{name.camelize} -- configuration library"
  licenses    << 'Apache-2.0'

  dependency             'json'
  dependency             'monetize'
  development_dependency 'rake'
  development_dependency 'simplecov'
  development_dependency 'rspec'
end

task :default => :spec

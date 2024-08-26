# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'complex_config'
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "https://github.com/flori/#{name}"
  summary     'configuration library'
  description 'This library allows you to access configuration files via a simple interface'
  executables 'complex_config'
  test_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage', '.rvmrc',
    '.AppleDouble', '.DS_Store', 'errors.lst', 'tags'
  package_ignore '.all_images', '.utilsrc', '.rspec', '.tool-versions',
    '.gitignore'

  readme      'README.md'
  title       "#{name.camelize} -- configuration library"
  licenses    << 'Apache-2.0'

  dependency             'json'
  dependency             'tins'
  dependency             'mize', '~> 0.3', '>= 0.3.4'
  dependency             'base64'
  development_dependency 'rake'
  development_dependency 'simplecov'
  development_dependency 'rspec'
  development_dependency 'monetize'
  development_dependency 'utils'
  development_dependency 'debug'
end

task :default => :spec

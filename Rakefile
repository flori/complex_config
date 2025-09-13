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
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage',
    '.AppleDouble', '.DS_Store', 'errors.lst', 'tags', 'doc', '.yardoc'
  package_ignore '.all_images.yml', '.utilsrc', '.rspec', '.tool-versions',
    '.gitignore', '.contexts'

  readme      'README.md'
  title       "#{name.camelize} -- configuration library"
  licenses    << 'Apache-2.0'

  clobber 'coverage'

  dependency             'json'
  dependency             'tins', '~> 1'
  dependency             'mize', '~> 0.6'
  dependency             'base64'
  development_dependency 'rake'
  development_dependency 'simplecov'
  development_dependency 'rspec'
  development_dependency 'monetize'
  development_dependency 'debug'
  development_dependency 'all_images',    '~> 0.8'
  development_dependency 'context_spook', '~> 0.4'
end

task :default => :spec

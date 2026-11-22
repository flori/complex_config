# Changes

## 2026-11-18 v0.28.0

### Build & CI
- Removed vim modeline comments from `Gemfile` and `Rakefile`.
- Updated development dependency `context_spook` from **0.4** to
  **1.8**.
- Updated development dependency `gem_hadar` from **2.21.0** to
  **2.24.1**.

## 2026-11-15 v0.27.0

### Fixes
- Corrected the `guidelins` meta key in the `code_comment` context to
  `guidelines` in `.contexts/code_comment.rb`.
- Fixed the `Proxy` documentation to replace a phantom `@attr_reader`
  with a proper YARD block for the `#complex_config_env` method.
- Corrected the `Settings#skip` documentation to state that it throws
  a `:skip` symbol rather than raising an exception.
- Clarified the `@return` tag for `Provider#write_config` to indicate
  that the key is returned whenever encrypting, not only when
  `store_key` is true.

### Improvements
- Rewrote the YARD cheatsheet in `.contexts/yard.md` as a
  documentation generation guide with a comprehensive example and
  rules for omitting executable code and void `@return` tags.

### Build & CI
- Updated `s.rubygems_version` to **4.0.24** in
  `complex_config.gemspec`.
- Bumped the `gem_hadar` development dependency constraint to
  **>= 2.21.0**.

### Documentation
- Added detailed header comments to `lib/complex_config/version.rb`
  explaining its auto-generated nature and regeneration via
  `rake version`.

## 2026-07-10 v0.26.0

### Breaking
- Deprecated `ComplexConfig::Settings#attributes_update_if_nil` in
  favor of the renamed `attributes_update_if_undefined`, which
  preserves explicit `nil` overrides.

### Features
- Added `ComplexConfig::Provider#decrypt_data` to support decryption
  of raw ciphertext without requiring a file path.
- Added `-k` flag to the `complex_config` CLI to specify an explicit
  key file path.
- Enabled streaming decryption from stdin to stdout in the
  `complex_config` CLI via the `-I` flag.

### Improvements
- Replaced `Tempfile.open` with `Tempfile.create` and appended a
  `.yml` suffix to temporary files in the encryption CLI for
  deterministic deletion and better editor syntax highlighting.
- Updated the Alpine build image to use stable Ruby **4.0** instead
  of **4.0-rc**.

### Build & CI
- Added a GitHub Actions workflow for automated documentation
  deployment to GitHub Pages using Ruby **3.4**.
- Updated `gem_hadar` dependency from **~> 2.10** to **>= 2.17.1**
  and `s.rubygems_version` from **4.0.2** to **4.0.10**.
- Added changelog configuration to the `Rakefile` using `GemHadar`.

### Testing
- Added test cases for `ComplexConfig::Provider#decrypt_config` and
  expanded coverage for `attributes_update` and
  `attributes_update_if_undefined`, including deprecation warnings.

### Documentation
- Expanded `README.md` with guides on secure secret comparison,
  automation piping, and critical security warnings regarding
  plain-text secrets.
- Added an `@example` block to
  `ComplexConfig::Provider#decrypt_config` documenting the automatic
  appending of the `.enc` extension.

## 2025-12-19 v0.25.0

### Breaking
- Replaced `Money.new(cents)` with
  `Money.from_cents(cents, currency.upcase)` in the `MONEY`
  plugin, requiring explicit currency handling for modern
  versions of the `money` gem.

### Features
- Added support for configurable default currency in the
  `MONEY` plugin via the
  `COMPLEX_CONFIG_MONEY_DEFAULT_CURRENCY` environment
  variable.
- Set the default currency to **EUR** when no environment
  variable is specified.

### Improvements
- Updated the `MONEY` plugin to use the `currency.upcase`
  method for proper currency string normalization.

### Build & CI
- Added `ruby:4.0-rc-alpine` to the test matrix in
  `.all_images.yml`.
- Changed `bundle update` to `bundle update --all` in
  `.all_images.yml` to ensure all gems are updated.
- Updated `s.rubygems_version` from **3.7.2** to **4.0.2**
  in the gemspec.
- Updated `gem_hadar` development dependency from **2.8**
  to **2.10**.

### Testing
- Added test coverage for default **EUR** and custom **BTC**
  currency scenarios.
- Implemented environment variable isolation in tests using
  `around` blocks.

## 2025-11-24 v0.24.0

### Features
- Added the `-O` option to the `complex_config decrypt` command to
  write output to standard output.
- Added the `-I` option to the `complex_config encrypt` command to read
  input from standard input.

### Improvements
- Replaced a custom exception with a `catch`/`throw` mechanism in the
  `edit` command to improve control flow.

### Build & CI
- Added the `openssl-dev` package to the Alpine Linux image
  configuration.
- Updated the `gem_hadar` development dependency from `~> 2.6` to
  `~> 2.8`.

## 2025-09-14 v0.23.0

### Documentation

- Documented encryption support, including AES-128-GCM usage, key management,
  and Rails integration.
- Added architecture, error handling, and debugging sections to the README.
- Added YARD documentation for all library classes and methods.
- Updated license link in the README to point to the `LICENSE` file.

### Build & CI

- Updated `.gitignore` and `Rakefile` to exclude `doc`, `.yardoc`, and
  `cscope.out` from packaging and version control.
- Updated SimpleCov configuration in `spec_helper.rb` to use
  `GemHadar::SimpleCov`.
- Added `context_spook` as a development dependency and updated
  `gem_hadar` to **2.6**.

### Improvements

- Added code indexing configuration and documentation context files to
  `.utilsrc` and `.contexts`.
- Added header comments and YARD documentation to `bin/complex_config` and
  refactored output formatting for improved readability.

## 2025-09-11 v0.22.3

### Breaking
- Upgraded runtime dependency `tins` from `>= 0` to `~> 1`.
- Upgraded runtime dependency `mize` from `~> 0.3` to `~> 0.6`.

### Fixes
- Removed the duplicate `master_key_pathname` writer attribute from
  `ComplexConfig::Provider`.

### Build & CI
- Added `yaml-dev` to the Docker image build packages.
- Installed `bundler` in the Docker image and replaced `gem update`
  with `gem_hadar`.
- Updated the build script to run `bundle update` and `bundle install`
  with `--jobs` for better performance.
- Added `fail_fast: true` to the `.all_images.yml` configuration.
- Updated `package_ignore` in `Rakefile` to explicitly target
  `.all_images.yml`.
- Removed `.all_images.yml` from the gem package file list.
- Updated `Rakefile` dependencies to match new version constraints
  for `tins` and `mize`.
- Added `all_images` as a development dependency in `Rakefile` and
  `complex_config.gemspec`.
- Updated development dependency `gem_hadar` to `~> 2.4`.
- Removed obsolete `binary false` option from `.utilsrc` discovery
  configuration.

### Testing
- Updated CI matrix to include `ruby:3.4-alpine` and removed
  `ruby:3.0-alpine`.
- Replaced `RSpec.describe` with `describe` across all spec files
  for cleaner syntax.

## 2024-10-21 v0.22.2

### Fixes
- Handle `Errno::ENOENT` and `Errno::ENOTDIR` errors in `KeySource`

### Testing
- Remove unneeded `allow` statement from `provider_spec.rb`
- Use `at_least(:once)` for `expect(provider).to receive(:env)` in `shortcuts_spec.rb`

## 2024-09-22 v0.22.1

### Fixes
- Handle `nil` values in `ComplexConfig::Settings` to prevent errors during
  conversion to hashes.

### Build & CI
- Removed the development dependency `utils`.

### Testing
- Updated `settings_spec.rb` to verify `nil` value handling in `to_h`,
  `pathes`, and serialization methods.

## 2024-09-12 v0.22.0

### Features
- Added `utf8` parameter to `Tree#initialize` to control encoding
  for tree display.
- Introduced `default_utf8` method to determine the default encoding
  based on environment variables.
- Updated `inner_child_prefix` and `last_child_prefix` to use ASCII
  or UTF-8 prefixes depending on the selected encoding.

### Testing
- Added a test to verify tree output with ASCII encoding.
- Updated existing pretty print tests to account for the new UTF-8
  behavior.

## 2024-09-09 v0.21.2

### Breaking
- Renamed `list` to `attributes_list` in `ComplexConfig::Settings`.

### Testing
- Updated `settings_spec.rb` to call `attributes_list`.

## 2024-09-09 v0.21.1

### Breaking
- The default string representation of `ComplexConfig` settings has been changed to a tree-like structure.
- The `to_s` method in `ComplexConfig::Settings` has been renamed to `list`.
- Calling `to_s` now returns the tree representation instead of the flat list.

### Improvements
- Added a new `list` method to `ComplexConfig::Settings` to retrieve the flat string representation of settings.
- Updated `pretty_print` to use the tree representation for consistency with `to_s`.

### Documentation
- Updated `README.md` to reflect the new tree-based default string output format.

### Testing
- Updated tests in `spec/complex_config/settings_spec.rb` to verify the new `list` and `to_s` behavior.

## 2024-09-09 v0.21.0

### Features
- Added `Tree` class to convert complex configuration objects into
  tree structures.
- Updated `Settings` class to utilize `Tree` conversion in the `to_tree`
  method.
- Added components array support for flux capacitors in configuration
  files.

### Fixes
- Added type check in `ComplexConfig::Settings#build` to raise `TypeError`
  for non-hash inputs.

### Improvements
- Renamed license file from `COPYING` to `LICENSE` for standard
  compliance.

### Build & CI
- Added clobber task for coverage in `Rakefile`.
- Updated `bundle` command to `bundle install --full-index` in `all_images`
  script.
- Updated `gem_hadar` dependency to **1.17.0**.
- Removed `.byebug_history` from `.gitignore`.
- Deleted `.tool-versions` file.
- Replaced `byebug` with `debug` in `spec_helper.rb`.

### Testing
- Added test case for reading from an empty configuration file.
- Updated tests to reflect `Tree` conversion changes.
- Added requirement for `tins/xt/ask_and_send` in `complex_config/provider.rb`.

## 2024-04-17 v0.20.0

### Build & CI
- Added a runtime dependency on the `base64` gem.
- Updated the development dependency on `gem_hadar` to **~> 1.15.0**.
- Added the `debug` gem as a development dependency.
- Upgraded the local Ruby version to **3.3.0**.
- Fixed the CI script to run `rake spec` instead of `rake test`.
- Updated the CI matrix to test Ruby **3.3** and removed older versions.

## 2022-07-11 v0.19.4

### Improvements
- Switch to `::YAML.unsafe_load` to support legacy classes in
  configuration files.

### Testing
- Add a test case to verify loading configuration files containing
  YAML legacy classes.

## 2022-05-19 v0.19.3

### Features
- Allow passing parameters to `ComplexConfig::Settings#to_json` to
  customize the JSON output.

### Build & CI
- Migrate CI configuration from Travis CI to all_images, testing
  Ruby **2.5** through **3.1** on Alpine.
- Remove development dependency on `forwardable` in the Money plugin,
  as it is now handled by `monetize`.
- Update `gem_hadar` development dependency to **~> 1.12.0**.
- Exclude development and tooling files from the packaged gem.

### Testing
- Add test coverage for JSON conversion of settings objects.

### Documentation
- Remove the embedded change log from the README.

## 2021-10-28 v0.19.2

### Features
- Added support for **Psych** **4.0.2** to retain YAML alias
  handling by using the `aliases: true` option when loading
  configuration files.

### Improvements
- Updated the Ruby version in `.tool-versions` to **3.0.2**.

### Testing
- Added a specification and a test fixture to verify that YAML
  files containing aliases are parsed correctly.

## 2021-04-09 v0.19.1

### Fixes
- Adapted to the new keyword interface of `ERB` for Ruby **3**.

### Build & CI
- Added Ruby **3.0** to the CI test matrix.

## 2021-01-05 v0.19.0

### Features
- Added `attribute_get` and `attribute_get!` methods to
  `ComplexConfig::Settings` for retrieving attributes by name,
  where `attribute_get!` raises `AttributeMissing` if the
  attribute is absent.

### Fixes
- Updated the `==` method in `ComplexConfig::Settings` to
  safely check if the other object responds to `to_h` before
  comparison, preventing errors with non-Hash-like objects.

### Testing
- Added a test case for the new `attribute_get!` method to
  verify it retrieves existing attributes and raises the
  appropriate exception for missing ones.

## 2020-08-26 v0.18.2

### Fixes
- Guard `Rails.root` access by checking
  `Rails.respond_to?(:root)` before invocation.

## 2020-08-26 v0.18.1

### Fixes
- Guard against undefined `Rails.env` by checking if `Rails`
  responds to `env` before calling it in the `env` method.

## 2020-01-07 v0.18.0

### Features
- Add support for **2.7.0**.

### Fixes
- Avoid mutating strings in `to_s` by using the `+`
  operator instead of `<<`.
- Avoid mutating strings in the URI plugin by duplicating
  the ID string before modification.

### Build & CI
- Add **2.7** to the Travis CI test matrix.
- Refactor gemspec dependencies to use the modern
  `add_runtime_dependency` and `add_development_dependency`
  methods.

## 2019-11-27 v0.17.1

### Fixes
- Refactor the handling of shared settings to prevent overwriting
  explicitly configured `nil` or `false` values with defaults.
- Introduce a new method, `attributes_update_if_nil`, in
  `ComplexConfig::Settings` to merge attributes only when the target
  value is `nil`.

### Improvements
- Update the `gem_hadar` development dependency requirement to `~> 1.11.0`.

### Testing
- Add test fixtures for `test` and `staging` environments to verify that
  explicit `null` and `false` shared settings are respected.
- Update `ComplexConfig::Provider` specs to expect `nil` and `false` for
  shared settings in `test` and `staging` environments, respectively.

### Build & CI
- Remove Ruby **2.0** from the Travis CI test matrix.
- Add `tags` to the `.gitignore` and the `Rakefile` ignore patterns.

## 2019-03-18 v0.17.0

### Fixes
- Fixed a decoding issue in `decrypt_config` by ensuring the full
  return tuple is used where appropriate.

### Documentation
- Updated the README changelog to reflect the new release **0.17.0**.

## 2019-03-18 v0.16.2

### Improvements
- Refactored `decrypt_config` to return status codes and handle missing keys and files.
- Improved error reporting in `config` for `ComplexConfig::EncryptionKeyMissing`.
- Ensured `exist?` returns `false` when the encryption key is missing.

## 2019-03-18 v0.16.1

### Fixes
- Introduced new `EncryptionKeyMissing` error class and raised
  in `decrypt_config` when the encryption key is not provided.

## 2019-03-14 v0.16.0

### Features
- Add `- trim_mode` to `ERB` evaluation in `ComplexConfig::Provider#evaluate`
  to strip leading newlines from template output.
- Enable `to_json` on `ComplexConfig::Settings` by delegating to `to_h`.

### Improvements
- Update `README.md` to document the new release features.

## 2019-03-14 v0.15.1

### Fixes
- Fixed an issue where shared features did not work correctly for empty top-level settings.

### Build & CI
- Added support for Ruby **2.6** in Travis CI.

### Testing
- Added test coverage for shared features with empty top-level settings.

## 2018-12-07 v0.15.0

### Features
- Added `recrypt` command to `bin/complex_config` for
  updating encrypted files in place with new keys.
- Added `new_key` command to generate and display a
  new cryptographic key.
- Implemented `new_key` and `valid_key?` methods in
  `ComplexConfig::Provider` to support key generation and
  validation.

## 2018-12-07 v0.14.1

### Fixes
- Raise `ComplexConfig::DecryptionFailed` when the decryption key
  is invalid or decryption fails with `OpenSSL::Cipher::CipherError`.
- Avoid exposing raw `auth_tag` details in error messages to
  prevent information leakage.

### Features
- Add `ComplexConfig::Settings#empty?` to check if the settings are
  empty.
- Return the class name string when calling `to_s` on an empty
  `ComplexConfig::Settings` instance.

### Improvements
- Ensure test compatibility with older Ruby versions by using
  `Tins::Token` for random bytes instead of `SecureRandom.bytes`.
- Refactor specs to use `described_class` for cleaner references.

### Build & CI
- Remove `TODO.md` file as it is no longer needed.

### Documentation
- Update `README.md` with recent release notes for **0.14.0**.

## 2018-06-07 v0.14.0

### Features
- Added a `complex_config` executable to edit, encrypt, decrypt,
  and display configuration files using `ComplexConfig::Provider`.
- Added `decrypt_config` and `encrypt_config` methods to
  `ComplexConfig::Provider` to handle encryption operations.

### Improvements
- Refactored `ComplexConfig::Provider#config` to utilize the new
  `decrypt_config` method.
- Removed `byebug` from development dependencies in `Gemfile`.

### Build & CI
- Updated gemspec to include `bin/complex_config` in executables
  and file list.

### Testing
- Added specs to verify encryption and decryption of file content
  using `RAILS_MASTER_KEY`.

## 2018-02-23 v0.13.3

### Improvements
- Reordered `key_source` to prioritize the `var` over `pathname`.

### Documentation
- Updated README to reflect the new key source evaluation order.

## 2018-02-23 v0.13.2

### Features
- Introduced `ComplexConfig::KeySource` to encapsulate the resolution logic for
  encryption keys from variables, environment variables, and file paths.
- Added support for a `master_key_pathname` attribute in
  `ComplexConfig::Provider`, which defaults to `config/master.key`.
- Modified `ComplexConfig::Proxy` to return an empty `ComplexConfig::Settings`
  object when the specified environment does not exist.

### Improvements
- Replaced the use of the safe navigation operator (`&.`) with
  `ask_and_send` in `ComplexConfig::KeySource` and `ComplexConfig::Provider`
  to ensure compatibility with older Ruby versions.
- Updated test fixtures to use standard heredoc syntax instead of squiggly
  heredocs for improved compatibility.
- Refactored `ComplexConfig::Provider` to use the new key source object for
  encryption and decryption operations.

### Testing
- Added tests for `ComplexConfig::KeySource` to verify key resolution from
  various sources and error handling for multiple settings.
- Added tests for `master_key_pathname` derivation and configuration in
  `ComplexConfig::Provider`.
- Added tests for shared configuration values across environments.
- Updated provider specs to verify key accessor behavior and cache sizing
  logic.

## 2018-02-09 v0.13.1

### Fixes
- Improved error reporting for encrypted files with a missing key.

### Build & CI
- Updated supported Ruby versions in the CI configuration to include **2.3**, **2.4**, and **2.5**.
- Updated the `rubygems` version requirement in the gemspec to **2.7.3**.

### Documentation
- Added release notes for **0.13.1** to the README.

## 2018-01-26 v0.13.0

### Breaking
- `write_config` now expects the value as the second argument or as a
  `value:` keyword argument.
- `write_config` with `encrypt: true` or a custom key now stores the key
  as a hex string instead of raw bytes.

### Improvements
- Added `key_as_bytes` method for reading keys from the environment,
  file, or provider settings.

### Testing
- Added test cases for `write_config` with various key sources including
  environment variables.
- Removed test for reading encrypted config using shell scripts.

### Documentation
- Updated `README.md` to document the `0.13.0` release.

## 2017-11-17 v0.12.2

### Fixes
- Output string keys for top-level configuration hashes to
  ensure compatibility with Rails.

### Improvements
- Refactor config writing to use `prepare_output` instead of
  relying directly on `ComplexConfig::Settings`.

## 2017-11-17 v0.12.1

### Fixes
- Prevented the output of trailing newlines when writing encrypted
  configurations and encryption keys in `ComplexConfig::Provider`.

### Documentation
- Updated the changelog in `README.md` to reflect the current release.

## 2017-11-16 v0.12.0

### Features
- Added the `write_config` method to `ComplexConfig::Provider`
  to support writing configuration files, with optional encryption
  and key storage.
- Added support for retrieving encryption keys from the
  `COMPLEX_CONFIG_KEY` environment variable.
- Added an `==` method to `ComplexConfig::Settings` for comparing
  configuration objects.

### Fixes
- Refactored encryption error classes to inherit from
  `ComplexConfigError` instead of `StandardError`.
- Validated that encryption keys are exactly 16 bytes long in
  `ComplexConfig::Encryption` and `ComplexConfig::Provider`.
- Changed `write_config` to return the hexadecimal key string
  instead of the provider instance.
- Used `SecureRandom.random_bytes` instead of `SecureRandom.bytes`
  to support older Ruby versions.
- Stripped whitespace from encryption keys obtained from files or
  environment variables.

### Build & CI
- Added a dependency on the `tins/xt/secure_write` library.

### Testing
- Added tests for writing plain and encrypted configurations,
  including key generation, storage, and retrieval scenarios.
- Added test fixtures for encrypted configurations with key files
  and shell scripts.

## 2017-11-02 v0.11.3

### Improvements
- Strip input strings in `base64_decode` and `read_key_from_file`
- Clear `mize` caches when `deep_freeze` is disabled
- Replace hash slicing with `shift` in `Provider#evaluate`

### Build & CI
- Update `mize` dependency constraint to `~> 0.3`, `>= 0.3.4`

## 2017-10-30 v0.11.2

### Fixes
- Prevent `ComplexConfig::ConfigurationFileMissing` errors when
  an encrypted file exists but its decryption key is not yet
  configured, by skipping the file during the setup process.

## 2017-10-27 v0.11.1

### Features
- Support shared features in configuration files.
- Merge configuration from plain and encrypted files.
- Add `ComplexConfig::Settings#attributes_update` for
  updating settings with another hash.

### Improvements
- Replace `::Errno::ENOENT` with explicit `ConfigurationFileMissing` error.
- Wrap variable, method, and constant names in backticks.

## 2017-10-27 v0.11.0

### Features
- Added support for reading and decrypting Rails encrypted
  YAML configuration files.
- Introduced `ComplexConfig::Encryption` class to handle
  AES-128-GCM encryption and decryption.
- Added `key` method to `ComplexConfig::Provider` to resolve
  encryption keys from file or `RAILS_MASTER_KEY`.
- Modified `evaluate` to accept data directly, enabling
  decryption before ERB evaluation.

### Testing
- Added specs for `ComplexConfig::Encryption` to verify
  encryption and decryption functionality.

### Build & CI
- Updated Ruby test version to **2.4.2** in Travis CI.

## 2017-02-02 v0.10.0

### Features
- Added `exist?` method to `ComplexConfig::Provider` to check for key existence.
- Supported suffix methods ending with `?` on the proxy object to return `nil`
  if the key does not exist.

### Testing
- Added tests for `?`-suffixed shortcut methods to verify return values for
  existing and missing keys.

### Documentation
- Updated the README changelog section to document the release **0.10.0** and
  the new `?`-method behavior.

## 2017-01-23 v0.9.2

### Improvements
- Improved performance by memoizing the `proxy` method and defining
  methods dynamically in `method_missing`.

### Build & CI
- Removed the `codeclimate-test-reporter` dependency and updated the
  Ruby version to **2.4.0** in the CI configuration.

## 2016-11-23 v0.9.1

### Fixes
- Fix Travis CI builds by stubbing the `RAILS_ENV`
  variable to prevent interference with specs.

### Build & CI
- Add Code Climate coverage via Travis CI addons and
  remove it from the environment variables.
- Update Ruby version tests to include **2.4.0-preview3**
  and **2.3.3**.
- Update `rubygems_version` to **2.6.8**.

## 2016-11-22 v0.9.0

### Features
- Extracted the provider shortcuts into the
  `ComplexConfig::Provider::Shortcuts` module and included it in
  `ComplexConfig::Provider` and `::Object`.

### Improvements
- Updated the `gem_hadar` dependency to `**1.9.1**`.

### Build & CI
- Configured CodeClimate test reporting to run only on successful
  builds.

## 2016-07-27 v0.8.0

### Features
- Added `replace_attributes` to `ComplexConfig::Settings` to
  support easier configuration testing.
- Changed `attr_reader :table` visibility from `private` to
  `protected` within `ComplexConfig::Settings`.

### Testing
- Added a spec verifying that `replace_attributes` successfully
  updates settings and returns the object instance.

### Documentation
- Updated the README to document the new `replace_attributes`
  functionality for `ComplexConfig::Settings`.

## 2016-07-18 v0.7.0

### Breaking
- Slimmed down the `ComplexConfig::Settings` interface to avoid clashes with methods mixed into the `Object` class or `Enumerable#instance_methods`.

### Improvements
- Updated the URI plugin to use `sub!` for in-place string modification.
- Added `pretty_print` and `freeze` methods to `ComplexConfig::Settings` for better interoperability.
- Changed `ComplexConfig::Settings` to inherit from `BasicObject` with minimal mixins.

### Testing
- Added specs for initializing, duplicating, sizing, and setting attributes in `ComplexConfig::Settings`.
- Removed obsolete tests for array-like behavior and `zip` method in settings.
- Updated provider plugin spec to handle specific evaluation cases.

### Documentation
- Documented changes for releases **0.7.0** and **0.6.0** in the README.

### Build & CI
- Bumped gem version to **0.7.0**.
- Updated the gemspec release date.

## 2016-07-15 v0.6.0

### Improvements
- Switched from `Tins` memoization to `mize` for caching in
  `ComplexConfig::Provider`.
- Replaced `memoize_method` and `memoize_cache_clear` with
  `memoize method: :[]` and `mize_cache_clear` to support
  the new caching library.

### Build & CI
- Added `mize` as a runtime dependency in the `Rakefile` and
  `complex_config.gemspec`.

## 2016-06-23 v0.5.2

### Fixes
- Resolved an issue where index access via the plugin code path was inconsistent, ensuring that `foo.bar` and `foo[:bar]` return the same result for a plugin key by updating the `[]` method in `ComplexConfig::Settings` to check `attribute_set?` and apply plugins before falling back to the original index behavior.

## 2016-06-23 v0.5.1

### Features
- Resolve index access via the plugin code path so `foo.bar` and
  `foo[:bar]` have the same result for a plugin key.

### Fixes
- Fixed typo in `README.md` where `c` was used instead of `cc`.

### Improvements
- Added `gem_hadar` version bump to `~> 1.7.1`.

### Build & CI
- Switched Travis CI to the new infrastructure by setting `sudo: false`.
- Added Ruby **2.3.1** and **2.4.0-preview1** to the CI test matrix.
- Marked `ruby-head`, `jruby-head`, and `2.4.0-preview1` as allowed
  failures in the CI matrix.

### Documentation
- Removed completed item regarding string representation of settings
  from `TODO.md`.

### Testing
- Added spec to verify index access for URI plugins.

## 2015-11-19 v0.5.0

### Features
- Added `ComplexConfig.configure` method to allow block-based
  configuration of `config_dir`, `env`, and plugins.
- Implemented `ComplexConfig::Railtie` to flush the provider cache
  during Rails preparation, supporting reloading behavior.
- Introduced `config_dir` accessor in `ComplexConfig::Provider` to
  define the base path for configuration files, replacing the
  previous `root` attribute.

### Improvements
- Updated `ComplexConfig::Provider#pathname` to resolve paths using
  the new `config_dir` method.

### Build & CI
- Included `.byebug_history` and `errors.lst` in `.gitignore` and
  Rakefile ignore list.

### Testing
- Added `spec/complex_config/config_spec.rb` to verify the behavior
  of the new `ComplexConfig.configure` interface.
- Updated `provider_spec` and `shortcuts_spec` to use `config_dir`
  instead of `root`.
- Modified `config_spec` to skip plugin execution to prevent test
  interference.

### Documentation
- Added a "Configuration" section to `README.md` demonstrating how
  to use `ComplexConfig.configure` and add plugins via block.
- Updated the `Changes` section in `README.md` to reflect release
  **0.5.0** features.

## 2015-11-17 v0.4.0

### Features
- Add `ComplexConfig::Proxy` to support root object method call syntax
  for accessing configurations, such as `cc.products` instead of `cc(:products)`.
- Update `complex_config` and `cc` shortcuts to return a proxy object
  when no configuration name is provided.
- Add `name_prefix` tracking to `ComplexConfig::Settings` to support the
  new proxy-based access pattern.
- Add `config/products.yml` as a sample configuration file for the new
  Rails-style directory structure.

### Improvements
- Update README to document the new method call syntax and note that
  the old `cc(:products)` syntax remains available for names that are
  not valid Ruby method identifiers.

### Testing
- Add specs for the new proxy behavior, including `reload` via
  shortcuts and alternative method syntax fallbacks.
- Adjust existing provider and shortcut specs to align with the new
  proxy-based interface and memoization order.

## 2015-11-03 v0.3.1

### Fixes
- Add missing `tins` runtime dependency to the gemspec.

### Improvements
- Shorten `CodeClimate::TestReporter` setup snippet in
  `spec/spec_helper.rb`.

### Build & CI
- Update `gem_hadar` development dependency to **1.3.1**.
- Add `monetize` and `codeclimate-test-reporter` as development
  dependencies in the Rakefile and gemspec.
- Remove `monetize` and `codeclimate-test-reporter` from the Gemfile
  to avoid redundancy with the gemspec.

### Documentation
- Update README to reflect improved settings output formatting.

## 2015-04-28 v0.3.0

### Features
- Add `ComplexConfig::Settings#pathes` to generate nested
  key paths from settings.
- Rework `ComplexConfig::Settings#to_s` to output a
  human-readable key-value format.

### Fixes
- Require `forwardable` in the Money plugin to prevent
  `LoadError` when `monetize` is loaded.

## 2015-03-24 v0.2.3

### Fixes
- Fixed typo `LoadErro` to `LoadError` in `ComplexConfig::Plugins::MONEY`.

### Build & CI
- Updated CI to use `jruby-head` and marked it as an allowed failure.

### Documentation
- Added release notes for **0.2.3** to `README.md`.

## 2015-02-25 v0.2.2

### Fixes
- Remove unnecessary `sprintf` format from the `pathname` method.

## 2015-01-28 v0.2.1

### Fixes
- Fixed requiring plugins so that enabling them correctly loads the `complex_config/plugins` file.
- Removed the top-level require for `complex_config/plugins` to allow using the gem without the `monetize` dependency.
- Skipped the `ComplexConfig::Plugins::MONEY` plugin when the `monetize` gem is not available.

### Improvements
- Made `monetize` an optional runtime dependency for the `MONEY` plugin.

### Build & CI
- Added a test target for JRuby.
- Removed the broken `jruby-head` test target.

### Documentation
- Updated the changelog section in the README.

## 2015-01-27 v0.2.0

### Features
- Replaced `Enumerable` mixin in `ComplexConfig::Settings` with method delegation
  to allow attributes to be named `zip`, `min`, or `max` without
  conflicting with standard Ruby methods.

### Fixes
- Updated `.travis.yml` to remove the patch version for Ruby `2.0.0` and
  added Ruby `2.2` to the CI build matrix.

### Testing
- Made test suite compatible with JRuby by scoping the `byebug` dependency
  to the `:mri` platform and wrapping its require in a `rescue LoadError`.
- Updated `attribute_names` expectation in `settings_spec.rb` to use an
  array of symbols instead of a symbol array literal for compatibility.
- Added tests for `ComplexConfig::Settings` attribute delegation and
  resolved pending tests for `AttributeMissing` errors.

### Documentation
- Added `COPYING` file containing the Apache License, Version 2.0 text.

### Build & CI
- Added `COPYING` to the `files` list in the gemspec.

## 2015-01-01 v0.1.1

### Fixes
- Fixed memory leak in `flush_cache` by ensuring it returns
  `self`.
- Added `to_ary` alias to `ComplexConfig::Settings` to prevent
  errors when calling `puts`.
- Updated `to_h` to correctly handle array values, ensuring that
  nested objects are converted while scalars remain unchanged.

### Testing
- Added specs to verify `to_ary` behavior, `flush_cache` return
  value, and `to_h` handling of mixed-type arrays.

### Documentation
- Updated `README.md` with release notes for the current version.
- Reordered items in `TODO.md` and added a new task for improving
  string representation.

## 2014-12-15 v0.1.0

### Features
- Deep-freeze cached configuration objects by default, with an
  option to disable this behavior.
- Added `deep_freeze` method to `ComplexConfig::Settings` to
  recursively freeze all nested values.
- Added `deep_freeze` accessor to `ComplexConfig::Provider` to
  control whether new configuration objects are frozen.

### Testing
- Added specs to verify that configuration objects are deep-frozen
  by default and that this behavior can be disabled.
- Refactored `ComplexConfig::Provider` specs to ensure cache is
  flushed after each test.
- Updated `ComplexConfig::Settings` specs to mark an attribute
  missing test as pending.

### Build & CI
- Added `codeclimate-test-reporter` as a development dependency for
  code coverage reporting.
- Added `TODO.md` to the list of files included in the gem package.

## 2014-12-12 v0.0.0

  * Start

# Changes

## 2024-10-21 v0.22.2

* Update file to handle ENOENT and ENOTDIR errors when reading from file:
  + Add `Errno::ENOTDIR` to rescue clause in `ComplexConfig::KeySource`
  + Rescue both `Errno::ENOENT` and `Errno::ENOTDIR` exceptions for robustness
* Improved test(s) in specs:
  + Removed unneeded `allow` statement from `provider_spec.rb`
  + Modified `shortcuts_spec.rb` to use `at_least(:once)` for `expect(provider).to receive(:env)`

## 2024-09-22 v0.22.1

#### Bug Fixes and Improvements

* Refactor ComplexConfig settings and specs to handle nil values:
  * Added `nil` handling in `ComplexConfig::Settings`
  * Updated `settings_spec.rb` to test for `nil` values
* Update dependencies and date in gemspec files:
  - Removed development dependency `'utils'` from Rakefile.
  - Updated date in `complex_config.gemspec` from "2024-09-13" to "2024-09-22"

* Bumped version to **0.22.1**:
  - Updated `VERSION` in `lib/complex_config/version.rb` from **0.22.0** to **0.22.1**
  - Updated `s.version` in `complex_config.gemspec` from **0.22.0** to **0.22.1**
  - Updated gem stub version in `complex_config.gemspec` from **0.22.0** to **0.22.1**

## 2024-09-12 v0.22.0

* **New Feature: UTF-8 Support**
  + Added `utf8` parameter to `Tree#initialize`
  + Introduced `default_utf8` method to determine default encoding based on environment variables
  + Modified `inner_child_prefix` and `last_child_prefix` methods for UTF-8 and ASCII encodings
  + Updated tests in `spec/complex_config/settings_spec.rb`

## 2024-09-09 v0.21.2

* **Settings List Method**:
  + Renamed `list` to `attributes_list`.
  + Updated tests in `settings_spec.rb` to use the new method name.

## 2024-09-09 v0.21.1

* **API Changes**:
  * The default string representation of ComplexConfig has been changed to a tree-like structure.
  * The `to_s` method in ComplexConfig::Settings has been renamed to `list`.
  * A new `list` method has been added to ComplexConfig::Settings for listing settings as a string.

## 2024-09-09 v0.21.0

* **Tree Representation**:
  + Add `Tree` class to convert complex config objects into trees.
  + Update `Settings` class to use `Tree` conversion in `to_tree` method.
  + Update tests to reflect changes.
* **Components Array**: Add components array for flux capacitors
* **Rakefile and Gemspec**:
  - Add clobber task for coverage to Rakefile
  - Update all_images script: update `bundle` to `bundle install --full-index`
* **.gitignore**: Remove `.byebug_history` from ignored files
* **Complex Config**:
  + Raise type error and add test for empty configuration file.
  + Update gemspec to use GemHadar 1.17.0
  + Add requirement for tins/xt/ask_and_send in complex_config/provider.rb
  + Add check for hash type in ComplexConfig::Settings#build method
  + Add test for reading from empty configuration file in provider_spec.rb
  + Replace byebug with debug in spec_helper.rb

## 2024-04-17 v0.20.0

#### Significant Changes

* **Add dependency to base64**: The code now depends on the `base64` library,
  which will be extracted from Ruby 3.4.
* **Upgrade ruby and add debug gem**: The project has been upgraded to use a
  newer version of Ruby and includes the `debug` gem for debugging purposes.
* **Use newest ruby, drop the older 2.5 version**: The code now targets the
  latest version of Ruby and no longer supports Ruby 2.5.

#### Other Changes

* Run specs: The project now runs its specifications as part of its build
  process.
* Test on newest ruby, on older ones don't: The project's tests are now run
  only on the latest version of Ruby, with older versions being skipped.
* Align: The code has been aligned to follow best practices.

## 2022-07-11 v0.19.4

* **Configuration File Handling Improvements**
    + Replaced defaulting to `unsafe_load` with explicit usage, ensuring safer
      handling of configuration files.

## 2022-05-19 v0.19.3

* **New Feature**: Pass parameters to json generator, allowing for more dynamic
  and customizable JSON output.
* **Improvement**: Use `all_images` for testing, improving the robustness and
  accuracy of image-related tests.

## 2021-10-28 v0.19.2

* **New Psych Support**
  + Added support for newest Psych 4 library
  + Defaults to disabling YAML alias feature
* **Psych API Update**
  + Updated code to use new Psych/YAML API when Psych version < 4
  + Retained behavior of evaluating aliases
* **Ruby Version Bump**
  + Updated Ruby version in tool-versions to 3.0.2

## 2021-04-09 v0.19.1

* **Breaking Change**: Updated code to adapt to the new keyword interface of
  ERB for Ruby versions greater than or equal to 3.

## 2021-01-05 v0.19.0

* Added two new methods:
  + `get_attribute_by_name`
  + `get_attributes_by_name`

## 2020-08-26 v0.18.2

* **Bug Fix**: Resolved a similar issue, mirroring the fix introduced in
  version 0.18.1.

## 2020-08-26 v0.18.1

* **New Feature**: Added support for faking data, allowing users to simulate
  scenarios without actual data.
    + Implemented a new module `FakeIt` with methods for generating fake data.
    + Updated relevant tests to include fake data scenarios.

## 2020-01-07 v0.18.0

* **New Version Summary**
  + Added support for Ruby 2.7.0
  + Updated tests to include Ruby 2.7.0
  + Refactored code to avoid string modifications
* Significant Changes:
  * Support added for Ruby 2.7.0
  * Tests updated to include Ruby 2.7.0
  * String modification stopped

## 2019-11-27 v0.17.1

* **Shared Settings Implementation**: The code now uses a more sane and
  efficient approach for shared settings.

## 2019-03-18 v0.17.0

* **Decoding Fix**: Corrected the decoding issue to ensure proper data
  interpretation.

## 2019-03-18 v0.16.2

* **New Feature**: Added support for handling complex scenarios
  + Implemented a new logic to handle intricate cases
* Improved error handling and reporting
  + Enhanced logging to provide more detailed information about errors
* Minor code refactoring
  + Simplified some conditional statements

## 2019-03-18 v0.16.1

* Improved error message for missing encryption key:
    + Added more informative and user-friendly error message when encryption
      key is not provided.

## 2019-03-14 v0.16.0

* **New Features**
  + Added support for `trim_mode` in legacy mode
  + Enabled `trim_mode` by default
  + Added `#to_json` method to settings objects
* **Changes**
  + Updated code to use new `trim_mode` feature
  + Modified settings objects to include `#to_json` method

## 2019-03-14 v0.15.1

* **Fix**: Shared feature now works correctly even when the top-level settings
  are empty.

## 2018-12-07 v0.15.0

* **New Feature**: Allow recrypting a file in-place with options.
    + Added functionality to enable recrypting a file without creating a new
      copy.

## 2018-12-07 v0.14.1

* **New Version**: Bumped version
* **Improved Error Handling**:
  + Improved error handling if key isn't valid
  + Raises `ComplexConfig::DecryptionFailed` for encrypted files
* **Compatibility**:
  + Make this run on older rubies
* **Documentation**:
  + Cleanup documentation
* **RubyGems**:
  + Use newest rubygems

## 2018-06-07 v0.14.0

* Added `complex_config` executable to handle configuration files.

## 2018-02-23 v0.13.3

* **Changes in Evaluation Order**
  + The evaluation order of key sources has been modified.

## 2018-02-23 v0.13.2

* **Compatibility improvements**
  + Be compatible with ancient rubies^3
  + Be compatible with ancient rubies^2
  + Be compatible with ancient rubies
* **Refactoring**
  + Refactor key provision with source object

## 2018-02-09 v0.13.1

* **New Features**
  + Added information to README file
* **Significant Changes**
  + Bumped version number
  + Improved error reporting for encrypted files with missing keys

## 2018-01-26 v0.13.0

* Improved the `write_config` interface
* Added more tests

## 2017-11-17 v0.12.2

* **Output string keys on top level configs**: 
  * Added functionality to output string keys on top level configurations.

## 2017-11-17 v0.12.1

* **New Feature**: Suppress newline output during encryption.

## 2017-11-16 v0.12.0

* **New Features**
  + Add support for writing configurations (encrypted or not)
* **Version Bump**
  + Bump version to 0.12.0
* **Compatibility Improvements**
  + Support older Rubies

## 2017-11-02 v0.11.3

* **New Feature:** Added striping functionality.
* **Bug Fix:** Fixed issue where caches were not cleared when `deep_freeze` was
  disabled.

## 2017-10-30 v0.11.2

* **Behavioral Fix**: 
  * Fixed the behavior for incomplete key setup.

## 2017-10-27 v0.11.1

* Added support for shared features.

## 2017-10-27 v0.11.0

* **New Feature**: Support for encrypted YAML files, compatible with Rails'
  encryption.
* **Test Update**: Added testing to ensure compatibility with Ruby 2.4.2.

## 2017-02-02 v0.10.0

## 2017-01-23 v0.9.2

* **New Version**: Released version 0.9.2.
* **Performance Improvement**:
  + Memoized proxy object for improved performance.

## 2016-11-23 v0.9.1

* **New Features**
  + Use newest RubyGems
  + Test on Ruby 2.3.3
* **Bug Fixes**
  + Fix Travis builds
  + travis fiddles with RAILS_ENV variable, breaking specs (resolved)
* **Testing Improvements**
  + Test newer Rubies

## 2016-11-22 v0.9.0

* **Gem Update**: Updated to newest gem_hadar.
* **Coverage Report**: Only send new coverage report on success.
* **Manual Run**: We are supposed to run this manually now.
* **Code Organization**: Moved provider shortcuts into its own module.

## 2016-07-27 v0.8.0

* **New Feature**: Added support for replacing attributes in
  `ComplexConfig::Settings` using the `#replace_attributes` method.

## 2016-07-18 v0.7.0

* **New Features**
  + Added new date functionality
* **Improvements**
    + Simplified `ComplexConfig::Settings` interface by basing it on
      `BasicObject` and reducing mixin usage
* **Documentation**
  + Updated README.md with new changes

## 2016-07-15 v0.6.0

* **Caching Improvements**
  + Use `mize` for caching

## 2016-06-23 v0.5.2

* **Index Access Feature**
  + Fixed issue with incorrect indexing behavior (#56190d3)
  + Improved performance and reliability of index access functionality

## 2016-06-23 v0.5.1

* **New Features**
    + Resolve index access via the plugin code path, making `foo.bar` and
      `foo[:bar]` equivalent for a plugin key.
    + Test on Ruby 2.3.1 and 2.4.0-preview1
* **Infrastructure Changes**
  + Use new infrastructure
* **Bug Fixes**
  + Fix typo

## 2015-11-19 v0.5.0

* **New Features**
  + Add configure method
  + Add configuration example to README
* **Bug Fixes**
  + Flush cache for every request in rails development
  + Change the Changes
* **Improvements**
  + Just always skip to avoid interference

## 2015-11-17 v0.4.0

* **New Feature:** Implemented root object method call syntax.

## 2015-11-03 v0.3.1

* **New Features**
  + Add missing tins dependency
  + Show improved settings output in README.md
  + Adds a decent string representation for ComplexConfig::Settings objects
* **Dependency Updates**
  + Use newest gem hadar
  + Add some development_dependencies (including tins)
* **Code Improvements**
  + Shorten codeclimate snippet

## 2015-03-24 v0.3.0

## 2015-03-24 v0.2.3

* **Typo Fix**: Corrected a typo in the `LoadErro(r)` method.
* **JRuby Update**: Updated JRuby version to use `jruby-head` and allowed it to
  potentially fail.

## 2015-02-25 v0.2.2

* Removed unnecessary `sprintf` format.

## 2015-01-28 v0.2.1

* **New Version**: 
  * Added support for JRuby test target
  * Removed always broken jruby-head
  * Bumped version number to 0.2.0
  * Bumped version to 0.2.1
* **Plugin Changes**:
  * Skip the money plugin if monetize cannot be loaded (optional runtime
    dependency)
  * Remove require for plugins, allowing users to use the gem without requiring
    the money gem
  * Fixed requiring *with* plugins, enabling them to load correctly

## 2015-01-27 v0.2.0

* **New Features**
  + Added support for JRuby in tests
  + Updated to newest Ruby 2.2
* **Improvements**
    + Replaced mixin with delegation for Enumerable, allowing attribute names
      like `zip`, `min`, or `max` without conflicts
* **Documentation**
  + Added Apache license file

## 2015-01-01 v0.1.1

* **New Version Summary**
  + Use value from non-associative list arrays
  + Fix `puts` method to call `to_ary` correctly
  + Prevent cash leakage after flushing cache
  + Add `to_ary` method for level on demand

## 2014-12-15 v0.1.0

* **Significant Changes**:
  + Freeze cached configuration by default (versioning)
  + Add to-do list for future development
  + Integrate CodeClimate for code analysis and improvement

## 2014-12-12 v0.0.0

  * Start

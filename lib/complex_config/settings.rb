require 'json'
require 'tins/xt/ask_and_send'
require 'tins/thread_local'

# A settings class that provides structured access to configuration data
#
# The Settings class serves as a container for configuration values, offering
# nested access through method calls and providing utilities for converting
# between different representations like hashes, YAML, and JSON. It supports
# environment-specific lookups and can be deeply frozen to prevent modification
# after initialization.
#
# @see ComplexConfig::Provider
# @see ComplexConfig::Config
# @see ComplexConfig::Settings#to_h
# @see ComplexConfig::Settings#to_yaml
# @see ComplexConfig::Settings#to_json
class ComplexConfig::Settings < BasicObject
  include ::Kernel
  include ::Tins::AskAndSend

  class << self

    # The [] method converts a hash-like object into a Settings object
    #
    # This method serves as a convenience accessor that delegates to the
    # from_hash class method, enabling quick conversion of hash-like structures
    # into ComplexConfig::Settings objects for structured configuration access.
    #
    # @param a [Object] the object to convert, which may respond to to_hash or to_ary
    #
    # @return [ComplexConfig::Settings, Array, Object] a Settings object if the
    #   input responds to to_hash, an array of converted elements if it responds to
    #   to_ary, or the original object if neither applies
    #
    # @see ComplexConfig::Settings.from_hash for the underlying conversion logic
    def [](*a)
      from_hash(*a)
    end

    # The from_hash method converts a hash-like object into a Settings object
    #
    # This method recursively processes hash-like objects and arrays,
    # converting them into Settings objects with appropriate nested structures
    # while preserving non-hash, non-array values as-is
    #
    # @param object [Object] the object to convert, which may respond to
    #   to_hash or to_ary
    #
    # @return [ComplexConfig::Settings, Array, Object] a Settings object if the
    #   input responds to to_hash, an array of converted elements if it
    #   responds to to_ary, or the original object if neither applies
    def from_hash(object)
      case
      when object.respond_to?(:to_hash)
        result = new
        object.to_hash.each do |key, value|
          result[key] = from_hash(value)
        end
        result
      when object.respond_to?(:to_ary)
        object.to_ary.map { |a| from_hash(a) }
      else
        object
      end
    end

    # The build method constructs a Settings object from a hash with optional
    # name prefixing
    #
    # This method takes a name and hash, sets the name as the prefix for the
    # Settings object, validates that the hash can be converted to a hash, then
    # converts it using from_hash. It ensures the name_prefix is reset to nil
    # after the operation completes.
    #
    # @param name [String, nil] The name to use as prefix for the Settings
    #   object, or nil
    #
    # @param hash [Object] The object to convert to a Settings object, must
    #   respond to to_hash
    #
    # @return [ComplexConfig::Settings] A new Settings object built from the
    #   provided hash
    #
    # @raise [TypeError] if the hash parameter does not respond to to_hash
    def build(name, hash)
      name.nil? or self.name_prefix = name.to_sym
      hash.respond_to?(:to_hash) or raise TypeError, 'require hash to build'
      from_hash(hash)
    ensure
      self.name_prefix = nil
    end

    extend Tins::ThreadLocal

    # The thread_local method sets up a thread-local variable for the
    # name_prefix attribute
    #
    # This method configures a thread-local storage mechanism for the
    # name_prefix attribute, allowing each thread to maintain its own
    # independent value for this attribute while sharing the same class-level
    # configuration.
    #
    # @return [String] the name prefix of the setting
    thread_local :name_prefix
  end

  # The name_prefix attribute accessor provides read and write access to the
  # name prefix setting
  #
  # This method allows getting and setting the name_prefix instance variable,
  # which is used to prefix configuration keys and provide context for
  # configuration lookups.
  #
  # @attr [String, nil] name_prefix the new name prefix value that was set
  attr_accessor :name_prefix

  # The initialize method sets up a new Settings object with optional hash
  # initialization
  #
  # This method creates a new instance of the Settings class, initializing it
  # with an optional hash of values. It sets the name_prefix from the
  # class-level attribute and prepares an internal table for storing
  # configuration attributes.
  #
  # @param hash [Hash, nil] An optional hash containing initial configuration values
  def initialize(hash = nil)
    self.name_prefix = self.class.name_prefix
    @table = {}
    if hash
      hash.each_pair do |k, v|
        k = k.to_sym
        @table[k] = v
      end
    end
  end

  # The initialize_copy method creates a duplicate of the current object
  #
  # This method is called when an object is being duplicated, typically through
  # the dup or clone methods. It performs a deep copy of the internal table
  # structure while preserving the object's state and ensuring that
  # modifications to the copy don't affect the original object.
  #
  # @param orig [Object] The original object being copied
  # @return [self] Returns the duplicated object instance for chaining
  def initialize_copy(orig)
    super
    @table = @table.dup
    self
  end

  # The attribute_set? method checks whether a specific attribute has been set
  # in the configuration
  #
  # This method verifies if a given attribute name exists in the internal table
  # of configuration settings, returning true if it has been explicitly set and
  # false otherwise. It converts the provided name to a symbol before
  # performing the lookup.
  #
  # @param name [Object] the name of the attribute to check for existence
  # @return [TrueClass, FalseClass] true if the attribute is set, false otherwise
  def attribute_set?(name)
    @table.key?(name.to_sym)
  end

  # The attribute_names method retrieves all attribute names stored in the
  # configuration
  #
  # This method provides access to the internal table of attribute names that
  # have been set on the current Settings object. It returns an array
  # containing all the symbolized keys that represent the configured
  # attributes.
  #
  # @return [Array<Symbol>] an array of symbolized attribute names that have
  #   been set on this Settings object
  def attribute_names
    @table.keys
  end

  # The attribute_values method retrieves all values stored in the
  # configuration table
  #
  # This method provides access to the internal table of configuration values,
  # returning an array containing all the values that have been set on the
  # current Settings object. It exposes the underlying data structure for
  # direct inspection or processing.
  #
  # @return [Array<Object>] an array of all configuration values stored in the
  # table
  def attribute_values
    @table.values
  end

  # The attributes_update method merges configuration attributes from another
  # source
  #
  # This method updates the current object's internal table with attributes
  # from another source, converting it to a Settings object if necessary. It
  # performs a deep merge of the attribute data while preserving the existing
  # structure.
  #
  # @param other [Object] the source containing attributes to merge, which can
  #   be any object that responds to to_hash or to_ary
  #
  # @return [void] Returns nothing
  def attributes_update(other)
    unless other.is_a? self.class
      other = self.class.from_hash(other)
    end
    @table.update(other.table)
  end

  # The attributes_update_if_nil method merges configuration attributes from
  # another source, updating only nil values
  #
  # This method updates the current object's internal table with attributes
  # from another source, but only assigns new values when the existing keys
  # have nil values. It preserves existing non-nil attribute values while
  # allowing nil values to be overridden.
  #
  # @param other [Object] the source containing attributes to merge, which can
  #   be any object that responds to to_hash or to_ary
  #
  # @return [void] Returns nothing
  def attributes_update_if_nil(other)
    unless other.is_a? self.class
      other = self.class.from_hash(other)
    end
    @table.update(other.table) do |key, oldval, newval|
      @table.key?(key) ? oldval : newval
    end
  end

  # The replace_attributes method replaces all attributes with those from the
  # provided hash
  #
  # This method updates the current object's internal table by replacing all
  # existing attributes with new ones derived from the given hash. It converts
  # the hash into a Settings object structure and then updates the internal
  # table with the new data.
  #
  # @param hash [Object] the source containing attributes to replace with,
  #   which can be any object that responds to to_hash or to_ary
  #
  # @return [self] returns self to allow for method chaining
  def replace_attributes(hash)
    @table = self.class.from_hash(hash).table
    self
  end

  #def write_config(encrypt: false, store_key: false)
  #  ::ComplexConfig::Provider.write_config(
  #    name_prefix, self, encrypt: encrypt, store_key: store_key
  #  )
  #  self
  #end

  # The to_h method converts the settings object into a hash representation
  #
  # This method recursively transforms the internal table of configuration
  # attributes into a nested hash structure, preserving the hierarchical
  # organization of settings while handling various value types including
  # arrays, nested settings objects, and primitive values.
  #
  # @return [Hash] a hash representation of the settings object with all nested
  #   structures converted to their hash equivalents
  def to_h
    table_enumerator.each_with_object({}) do |(k, v), h|
      h[k] =
        if v.respond_to?(:to_ary)
          v.to_ary.map { |x| (x.ask_and_send(:to_h) rescue x) || x }
        elsif v.respond_to?(:to_h)
          if v.nil?
            nil
          else
            v.ask_and_send(:to_h) rescue v
          end
        else
          v
        end
    end
  end

  # The == method compares this settings object with another object for
  # equality
  #
  # This method checks if the given object responds to to_h and then compares
  # the hash representation of this settings object with the hash
  # representation of the other object to determine if they are equal
  #
  # @param other [Object] the object to compare with this settings object
  # @return [TrueClass, FalseClass] true if the other object responds to to_h
  #   and their hash representations are equal, false otherwise
  def ==(other)
    other.respond_to?(:to_h) && to_h == other.to_h
  end

  # The to_yaml method converts the settings object into YAML format
  #
  # This method transforms the configuration data stored in the settings object
  # into a YAML string representation, making it suitable for serialization and
  # storage in YAML files.
  #
  # @return [String] a YAML formatted string representation of the settings object
  def to_yaml
    to_h.to_yaml
  end

  # The to_json method converts the settings object into JSON format
  #
  # This method transforms the configuration data stored in the settings object
  # into a JSON string representation, making it suitable for serialization and
  # interchange with other systems that consume JSON data.
  #
  # @param a [Array] Additional arguments to pass to the underlying to_json method
  #
  # @return [String] a JSON formatted string representation of the settings object
  def to_json(*a)
    to_h.to_json(*a)
  end

  # The to_tree method converts the settings object into a tree representation
  #
  # This method transforms the hierarchical configuration data stored in the
  # settings object into a tree structure that can be used for visualization or
  # display purposes. It utilizes the Tree.convert class method to perform the
  # actual conversion process.
  #
  # @return [ComplexConfig::Tree] a tree representation of the settings object
  #   hierarchy
  def to_tree
    ::ComplexConfig::Tree.convert(name_prefix, self)
  end

  # The size method returns the number of attributes in the settings object
  #
  # This method counts all configured attributes by enumerating through the
  # internal table and returning the total number of key-value pairs stored in
  # the settings object
  #
  # @return [Integer] the count of attributes stored in this settings object
  def size
    each.count
  end

  # The empty? method checks whether the settings object contains no attributes
  #
  # This method determines if the current Settings object has zero configured
  # attributes by comparing its size to zero. It provides a convenient way to
  # test for emptiness without having to manually check the size or iterate
  # through all attributes.
  #
  # @return [TrueClass, FalseClass] true if the settings object has no
  #   attributes, false otherwise
  def empty?
    size == 0
  end

  # The attributes_list method generates a formatted string representation of
  # all configuration attributes
  #
  # This method creates a human-readable list of all configuration attributes
  # by combining their paths and values into a structured format with
  # customizable separators for paths and key-value pairs
  #
  # @param pair_sep [String] the separator to use between attribute paths and
  #   their values, defaults to ' = '
  #
  # @param path_sep [String] the separator to use between path components,
  #   defaults to '.'
  #
  # @return [String] a formatted string containing all attribute paths and
  #   their corresponding values  or the class name if no attributes are
  #   present
  def attributes_list(pair_sep: ' = ', path_sep: ?.)
    empty? and return self.class.name
    pathes(path_sep: path_sep).inject('') do |result, (path, value)|
      result + "#{path}#{pair_sep}#{value.inspect}\n"
    end
  end

  # The to_s method provides a string representation of the settings object
  #
  # This method returns a human-readable string representation of the settings
  # object, either by returning the class name when the object is empty, or by
  # converting the object to a tree structure and then to a string for
  # non-empty objects
  #
  # @param a [Array] Additional arguments passed to the method (not used)
  # @return [String] The string representation of the settings object
  def to_s(*a)
    empty? and return self.class.name
    to_tree.to_s
  end

  # The pathes method recursively builds a hash of configuration paths and
  # their values
  #
  # This method traverses a nested hash structure and constructs a flattened
  # hash where keys are dot-separated paths representing the hierarchical
  # structure of the original data, and values are the corresponding leaf
  # values from the original structure
  #
  # @param hash [Hash] the hash to process, defaults to the instance's table
  # @param path_sep [String] the separator to use between path components, defaults to '.'
  # @param prefix [String] the prefix to prepend to each path, defaults to the name_prefix
  # @param result [Hash] the hash to accumulate results in, defaults to an empty hash
  # @return [Hash] a flattened hash with paths as keys and values as leaf values
  def pathes(hash = table, path_sep: ?., prefix: name_prefix.to_s, result: {})
    hash.each do |key, value|
      path = prefix.empty? ? key.to_s : "#{prefix}#{path_sep}#{key}"
      case value
      when ::ComplexConfig::Settings
        pathes(
          value,
          path_sep: path_sep,
          prefix:   path,
          result:   result
        )
      when ::Array
        value.each_with_index do |v, i|
          sub_path = path + "[#{i}]"
          if ::ComplexConfig::Settings === v
            pathes(
              v,
              path_sep: path_sep,
              prefix:   sub_path,
              result:   result
            )
          else
            result[sub_path] = v
          end
        end
      else
        result[path] = value
      end
    end
    result
  end

  alias inspect to_s

  # The pretty_print method formats the object for pretty printing
  #
  # This method takes a PrettyPrint object and uses it to format the object's
  # string representation for display purposes
  #
  # @param q [PrettyPrint] the pretty printer object to use for formatting
  # @return [void] Returns nothing
  def pretty_print(q)
    q.text inspect
  end

  # The freeze method freezes the internal table and calls the superclass
  # freeze method
  #
  # This method ensures that the configuration data stored in the internal
  # table is frozen, preventing further modifications to the configuration
  # settings. It then delegates to the parent class's freeze method to complete
  # the freezing process.
  #
  # @return [self] Returns self to allow for method chaining after freezing
  def freeze
    @table.freeze
    super
  end

  # The deep_freeze method recursively freezes all nested objects within the
  # configuration
  #
  # This method traverses the internal table of configuration attributes and
  # applies deep freezing to each value, ensuring that all nested settings
  # objects and their contents are immutable It also freezes the internal table
  # itself to prevent modification of the attribute structure
  #
  # @return [self] Returns self to allow for method chaining after freezing
  def deep_freeze
    table_enumerator.each do |_, v|
      v.ask_and_send(:deep_freeze) || (v.freeze rescue v)
    end
    freeze
  end

  # The attribute_get method retrieves a configuration attribute value by name
  #
  # This method attempts to fetch a configuration attribute value first from
  # the internal table, and if the attribute is not set, it applies registered
  # plugins to generate a value. It provides a unified way to access
  # configuration attributes that may be dynamically generated.
  #
  # @param name [Object] the name of the attribute to retrieve
  # @return [Object, nil] the value of the attribute if found, or nil if not
  #   found
  def attribute_get(name)
    if !attribute_set?(name) and
      value = ::ComplexConfig::Provider.apply_plugins(self, name)
    then
      value
    else
      @table[name.to_sym]
    end
  end

  # Alias for {attribute_get}
  #
  # @see attribute_get
  alias [] attribute_get

  # The attribute_get! method retrieves a configuration attribute value by
  # name, raising an exception if the attribute is not set
  #
  # @param name [Object] the name of the attribute to retrieve
  # @return [Object] the value of the attribute if found
  # @raise [ComplexConfig::AttributeMissing] if the attribute is not set and no
  #   plugin can provide a value
  def attribute_get!(name)
    if attribute_set?(name)
      attribute_get(name)
    else
      raise ::ComplexConfig::AttributeMissing, "no attribute named #{name.inspect}"
    end
  end

  # The []= method assigns a value to a configuration attribute
  #
  # This method stores a configuration attribute value in the internal table
  # using the attribute name as a symbol key. It converts the attribute name
  # to a symbol before storing the value.
  #
  # @param name [Object] the name of the attribute to assign
  # @param value [Object] the value to assign to the attribute
  # @return [Object] the assigned value
  def []=(name, value)
    @table[name.to_sym] = value
  end

  # The each method iterates over all configuration attributes
  #
  # This method provides enumeration support for the configuration settings,
  # yielding each key-value pair from the internal table to the provided block.
  # It delegates to the table enumerator to ensure consistent iteration behavior
  # across different contexts.
  #
  # @yield [key, value] Yields each configuration attribute key and its
  #   corresponding value
  # @yieldparam key [Object] The configuration attribute key
  # @yieldparam value [Object] The configuration attribute value
  # @return [self] Returns self to allow for method chaining after enumeration
  def each(&block)
    table_enumerator.each(&block)
  end

  protected

  # The table attribute reader provides access to the internal hash table
  # storing configuration attributes
  #
  # This method returns the internal @table instance variable that holds all
  # configuration attributes and their values for this settings object. The
  # returned hash is used internally for fast lookup of configuration values
  # and is not intended to be modified directly by external code.
  #
  # @return [Hash] the internal hash table containing all configuration
  #   attributes and their values
  # @api private
  attr_reader :table

  private

  # The table_enumerator method provides an enumerator for iterating over the
  # internal configuration table
  #
  # This method returns an enumerator object that can be used to iterate over
  # all key-value pairs stored in the internal @table instance variable. It
  # delegates to the enum_for method of the @table hash to provide consistent
  # enumeration behavior.
  #
  # @return [Enumerator] an enumerator for the internal configuration table hash
  def table_enumerator
    @table.enum_for(:each)
  end

  # The respond_to_missing? method determines if the object responds to a given
  # method name
  #
  # This method is part of Ruby's method missing protocol and is used to
  # dynamically determine whether the object should be considered as responding
  # to a particular method. It checks if the method name ends with a question
  # mark (indicating a safe navigation query) or if the corresponding attribute
  # has been explicitly set.
  #
  # @param id [Object] the method name being checked
  # @param include_private [Boolean] whether to consider private methods
  #   (unused in this implementation)
  # @return [Boolean] true if the object responds to the method, false otherwise
  def respond_to_missing?(id, include_private = false)
    id =~ /\?\z/ || attribute_set?(id)
  end

  # The skip method raises a skip exception to bypass plugin execution
  #
  # @return [void] This method always raises a :skip exception and never
  #   returns normally
  def skip
    throw :skip
  end

  # The method_missing method handles dynamic attribute access and assignment
  #
  # This method intercepts calls to undefined methods on the Settings object,
  # providing support for attribute retrieval, assignment, existence checking,
  # and plugin-based value resolution. It processes method names ending with
  # '?' for existence checks or safe navigation, '=' for assignment, and other
  # names for attribute lookup or plugin execution.
  #
  # @param id [Object] The name of the method being called
  # @param a [Array] Arguments passed to the method
  # @param b [Proc] Block passed to the method
  #
  # @return [Object] The result of the dynamic attribute operation
  def method_missing(id, *a, &b)
    case
    when id =~ /\?\z/
      begin
        public_send $`.to_sym, *a, &b
      rescue ::ComplexConfig::AttributeMissing
        nil
      end
    when id =~ /=\z/
      @table[$`.to_sym] = a.first
    when value = ::ComplexConfig::Provider.apply_plugins(self, id)
      value
    else
      if attribute_set?(id)
        @table[id]
      else
        raise ::ComplexConfig::AttributeMissing, "no attribute named #{id.inspect}"
      end
    end
  end
end

module ComplexConfig
  # A tree class that provides hierarchical representation of configuration
  # data
  #
  # The Tree class is used to create visual tree structures from configuration
  # data, allowing for easy display and understanding of nested configuration
  # settings. It supports both UTF-8 and ASCII character sets for rendering
  # tree connections and can handle various data types including Settings
  # objects, hashes, arrays, and primitive values.
  #
  # @see ComplexConfig::Settings
  # @see ComplexConfig::Tree#to_s
  # @see ComplexConfig::Tree#to_a
  class Tree
    # The convert method transforms configuration data into a tree structure
    #
    # This method recursively processes configuration values and converts them
    # into a hierarchical tree representation. It handles different value types
    # including ComplexConfig::Settings objects, Hashes, Arrays, and primitive
    # values, creating appropriate tree nodes for each case.
    #
    # @param name [Object] The name or key to use for the tree node
    # @param value [Object] The configuration value to convert, which can be a
    #   ComplexConfig::Settings object, Hash, Array, or primitive value
    # @return [ComplexConfig::Tree] A tree object representing the hierarchical
    #   structure of the configuration data
    def self.convert(name, value)
      case value
      when ComplexConfig::Settings
        convert(name, value.to_h)
      when Hash
        obj = new(name.to_s)
        value.each do |name, value|
          obj << convert(name, value)
        end
        obj
      when Array
        obj = new(name.to_s)
        value.each_with_index do |value, i|
          obj << convert(i, value)
        end
        obj
      else
        if name.is_a?(Integer)
          new value.inspect
        else
          new "#{name} = #{value.inspect}"
        end
      end
    end

    # The initialize method sets up a new tree node with the specified name and
    # UTF-8 support configuration.
    #
    # @param name [Object] The name or key to use for the tree node
    # @param utf8 [Boolean] Whether to use UTF-8 characters for tree rendering,
    #   defaults to the result of default_utf8
    def initialize(name, utf8: default_utf8)
      @name     = name
      @utf8     = utf8
      @children = []
    end

    # The default_utf8 method determines whether UTF-8 character support should
    # be enabled
    #
    # This method checks the LANG environment variable to determine if UTF-8
    # encoding should be used for tree rendering.
    #
    # @return [TrueClass, FalseClass] true if the LANG environment variable indicates
    #   UTF-8 encoding, false otherwise
    def default_utf8
      !!(ENV['LANG'] =~ /utf-8\z/i)
    end

    private

    # The inner_child_prefix method determines the appropriate prefix string
    # for tree child nodes
    #
    # This method returns a Unicode or ASCII character sequence used to
    # visually represent the connection between parent and child nodes in a
    # tree structure, depending on whether UTF-8 characters are enabled and
    # whether the current node is the first child
    #
    # @param i [Integer] the index of the child node in relation to its siblings
    # @return [String] the prefix string for the child node visualization
    def inner_child_prefix(i)
      if @utf8
        i.zero? ? "├─ " : "│  "
      else
        i.zero? ? "+- " : "|  "
      end
    end

    # The last_child_prefix method determines the appropriate prefix string for
    # tree child nodes
    #
    # @param i [Integer] the index of the child node in relation to its siblings
    # @return [String] the prefix string for the last child node visualization
    def last_child_prefix(i)
      if @utf8
        i.zero? ? "└─ " : "   "
      else
        i.zero? ? "`- " : "   "
      end
    end

    public

    # The to_enum method creates an enumerator for tree traversal
    #
    # This method generates an Enumerator that yields string representations of
    # the tree structure, including node names and their hierarchical
    # relationships. It processes children recursively and applies appropriate
    # prefix characters based on UTF-8 support and child position to visually
    # represent the tree structure.
    #
    # @return [Enumerator] An enumerator that yields formatted tree node strings
    #   in a hierarchical format with proper indentation and connection characters
    def to_enum
      Enumerator.new do |y|
        y.yield @name

        @children.each_with_index do |child, child_index|
          children_enum = child.to_enum
          if child_index < @children.size - 1
            children_enum.each_with_index do |setting, i|
              y.yield "#{inner_child_prefix(i)}#{setting}"
            end
          else
            children_enum.each_with_index do |setting, i|
              y.yield "#{last_child_prefix(i)}#{setting}"
            end
          end
        end
      end
    end

    # The << method appends a child node to the tree structure
    #
    # @param child [ComplexConfig::Tree] the child tree node to add to this
    #   node's children
    # @return [self] returns self to allow for method chaining after adding the
    #   child node
    def <<(child)
      @children << child
    end

    # The to_ary method converts the tree structure to an array representation
    #
    # This method generates an array containing string representations of all
    # nodes in the tree structure, including their hierarchical relationships
    # and proper indentation with connection characters. It delegates to the
    # to_enum method to produce the underlying enumeration before converting it
    # to an array.
    #
    # @return [Array<String>] an array of formatted strings representing the tree
    #   structure with proper indentation and visual connections between parent
    #   and child nodes
    def to_ary
      to_enum.to_a
    end

    # Alias for {to_ary}
    #
    # @see to_ary
    alias to_a to_ary

    # The to_str method converts the tree structure to a string representation
    #
    # This method generates a string by joining all node representations in the
    # tree with newline characters, providing a flat text representation of the
    # hierarchical structure.
    #
    # @return [String] a newline-separated string containing all tree node representations
    def to_str
      to_ary * ?\n
    end

    # Alias for {to_str}
    #
    # @see to_str
    alias to_s to_str
  end
end

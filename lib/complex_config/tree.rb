module ComplexConfig
  class Tree
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

    def initialize(name, utf8: default_utf8)
      @name     = name
      @utf8     = utf8
      @children = []
    end

    def default_utf8
      !!(ENV['LANG'] =~ /utf-8\z/i)
    end

    private

    def inner_child_prefix(i)
      if @utf8
        i.zero? ? "├─ " : "│  "
      else
        i.zero? ? "+- " : "|  "
      end
    end

    def last_child_prefix(i)
      if @utf8
        i.zero? ? "└─ " : "   "
      else
        i.zero? ? "`- " : "   "
      end
    end

    public

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

    def <<(child)
      @children << child
    end

    def to_ary
      to_enum.to_a
    end

    alias to_a to_ary

    def to_str
      to_ary * ?\n
    end

    alias to_s to_str
  end
end

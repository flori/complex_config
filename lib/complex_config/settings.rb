require 'json'
require 'tins/xt/ask_and_send'
require 'tins/thread_local'

class ComplexConfig::Settings < BasicObject
  include ::Kernel
  include ::Tins::AskAndSend

  class << self
    def [](*a)
      from_hash(*a)
    end

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

    def build(name, hash)
      name.nil? or self.name_prefix = name.to_sym
      from_hash(hash)
    ensure
      self.name_prefix = nil
    end

    extend Tins::ThreadLocal

    thread_local :name_prefix
  end

  attr_accessor :name_prefix

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

  def initialize_copy(orig)
    super
    @table = @table.dup
    self
  end

  def attribute_set?(name)
    @table.key?(name.to_sym)
  end

  def attribute_names
    @table.keys
  end

  def attribute_values
    @table.values
  end

  def attributes_update(other)
    unless other.is_a? self.class
      other = self.class.from_hash(other)
    end
    @table.update(other.table)
  end

  def replace_attributes(hash)
    @table = self.class.from_hash(hash).table
    self
  end

  def to_h
    table_enumerator.each_with_object({}) do |(k, v), h|
      h[k] =
        if ::Array === v
          v.to_ary.map { |x| (x.ask_and_send(:to_h) rescue x) || x }
        elsif v.respond_to?(:to_h)
          v.ask_and_send(:to_h) rescue v
        else
          v
        end
    end
  end

  def size
    each.count
  end

  def to_s(pair_sep: ' = ', path_sep: ?.)
    pathes(path_sep: path_sep).inject('') do |result, (path, value)|
      result << "#{path}#{pair_sep}#{value.inspect}\n"
    end
  end

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

  def pretty_print(q)
    q.text inspect
  end

  def freeze
    @table.freeze
    super
  end

  def deep_freeze
    table_enumerator.each do |_, v|
      v.ask_and_send(:deep_freeze) || (v.freeze rescue v)
    end
    freeze
  end

  def [](name)
    if !attribute_set?(name) and
      value = ::ComplexConfig::Provider.apply_plugins(self, name)
    then
      value
    else
      @table[name.to_sym]
    end
  end

  def []=(name, value)
    @table[name.to_sym] = value
  end

  def each(&block)
    table_enumerator.each(&block)
  end

  protected

  attr_reader :table

  private

  def table_enumerator
    @table.enum_for(:each)
  end

  def respond_to_missing?(id, include_private = false)
    id =~ /\?\z/ || attribute_set?(id)
  end

  def skip
    throw :skip
  end

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

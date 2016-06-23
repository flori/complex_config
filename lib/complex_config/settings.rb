require 'json'
require 'tins/xt/ask_and_send'
require 'tins/thread_local'

class ComplexConfig::Settings < JSON::GenericObject
  def self.[](*a)
    from_hash *a
  end

  class << self
    extend Tins::ThreadLocal

    thread_local :name_prefix
  end

  attr_accessor :name_prefix

  def self.build(name, hash)
    name.nil? or self.name_prefix = name.to_sym
    self[hash]
  ensure
    self.name_prefix = nil
  end

  def initialize(*)
    self.name_prefix = self.class.name_prefix
    super
  end

  def attribute_set?(name)
    table.key?(name.to_sym)
  end

  def attribute_names
    table.keys
  end

  def attribute_values
    table.values
  end

  def to_h
    table_enumerator.each_with_object({}) do |(k, v), h|
      h[k] =
        if Array === v
          v.to_ary.map { |x| (x.ask_and_send(:to_h) rescue x) || x }
        elsif v.respond_to?(:to_h)
          v.ask_and_send(:to_h) rescue v
        else
          v
        end
    end
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
      when ComplexConfig::Settings
        pathes(
          value,
          path_sep: path_sep,
          prefix:   path,
          result:   result
        )
      when Array
        value.each_with_index do |v, i|
          sub_path = path + "[#{i}]"
          if ComplexConfig::Settings === v
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


  def to_ary(*a, &b)
    table_enumerator.__send__(:to_a, *a, &b)
  end

  alias inspect to_s

  def deep_freeze
    table_enumerator.each do |_, v|
      v.ask_and_send(:deep_freeze) || (v.freeze rescue v)
    end
    freeze
  end

  def [](name)
    public_send(name)
  end

  private

  def table_enumerator
    table.enum_for(:each)
  end

  def respond_to_missing?(id, include_private = false)
    id =~ /\?\z/ || super
  end

  def skip
    throw :skip
  end

  def method_missing(id, *a, &b)
    case
    when id =~ /\?\z/
      begin
        public_send $`.to_sym, *a, &b
      rescue ComplexConfig::AttributeMissing
        nil
      end
    when id =~ /=\z/
      super
    when value = ComplexConfig::Provider.apply_plugins(self, id)
      value
    else
      if attribute_set?(id)
        super
      elsif table.respond_to?(id)
        table.__send__(id, *a, &b)
      else
        raise ComplexConfig::AttributeMissing, "no attribute named #{id.inspect}"
      end
    end
  end
end

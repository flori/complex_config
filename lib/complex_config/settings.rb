require 'json'
require 'tins/xt/ask_and_send'

class ComplexConfig::Settings < JSON::GenericObject
  def self.[](*a)
    from_hash *a
  end

  def each(&block)
    table.each(&block)
  end
  include Enumerable

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
    each_with_object({}) do |(k, v), h|
      h[k] = if Array === v
               v.to_ary.map { |x| (x.ask_and_send(:to_h) rescue x) || x }
             elsif v.respond_to?(:to_h)
               v.ask_and_send(:to_h) rescue v
             else
               v
             end
    end
  end

  def to_s
    to_h.to_yaml
  end

  alias to_ary to_a

  alias inspect to_s

  def deep_freeze
    each do |_, v|
      v.ask_and_send(:deep_freeze) || (v.freeze rescue v)
    end
    freeze
  end

  private

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
      else
        raise ComplexConfig::AttributeMissing, "no attribute named #{id.inspect}"
      end
    end
  end
end

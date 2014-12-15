require 'spec_helper'

RSpec.describe ComplexConfig::Settings do
  let :settings do
    ComplexConfig::Settings[
      foo: {
        bar: {
          baz: true
        },
        qux: 'quux'
      }
    ]
  end

  it 'can display its attribute_names' do
    expect(settings.foo.attribute_names).to eq %i[ bar qux ]
  end

  it 'can display its attribute_values' do
    values = settings.foo.attribute_values
    expect(values.first.to_h).to eq(baz: true)
    expect(values.last).to eq 'quux'
  end

  it 'can return the value of an attribute' do
    expect(settings.foo.bar.baz).to eq true
  end

  it 'can be converted into a hash' do
    expect(settings.foo.to_h).to eq(bar: { baz: true }, qux: 'quux')
  end

  it 'can be represented as a string' do
    expect(settings.to_s).to eq <<EOT
---
:foo:
  :bar:
    :baz: true
  :qux: quux
EOT
  end
  it 'raises exception if expected attribute is missing' do
    pending "still doesn't work"
    expect { settings.nix }.to raise_error(ComplexConfig::AttributeMissing)
  end

  it 'can be checked for set attributes' do
    expect(settings.foo.attribute_set?(:bar)).to eq true
    expect(settings.foo.bar?).to be_truthy
    expect(settings.foo.attribute_set?(:baz)).to eq false
    #expect(settings.foo.baz?).to be_falsy
  end
end


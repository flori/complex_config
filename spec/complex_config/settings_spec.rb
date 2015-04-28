require 'spec_helper'

RSpec.describe ComplexConfig::Settings do
  before do
    # Disable all plugins for this spec b/c they interfere with how rspec works
    allow(ComplexConfig::Provider.instance).to receive(:plugins).and_return([])
  end

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

  it "can return an attribute's value" do
    expect(settings.foo.bar.baz).to eq true
  end

  it 'can display its attribute_names' do
    expect(settings.foo.attribute_names).to eq [ :bar, :qux ]
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

  it 'can return a hash with pathes as keys' do
    expect(settings.pathes(path_sep: ?:)).to eq(
      'foo:bar:baz' => true,
      'foo:qux'     => "quux"
    )
  end

  it 'can be represented as a string' do
    expect(settings.to_s(pair_sep: ' → ', path_sep: ?/)).to eq <<EOT
foo/bar/baz → true
foo/qux → "quux"
EOT
  end

  it 'can be represented as a string if it has arrays' do
    settings[:ary] = ComplexConfig::Settings[ [ 1, { nested: 2 }, 3 ] ]
    expect(settings.to_s).to eq <<EOT
foo.bar.baz = true
foo.qux = "quux"
ary[0] = 1
ary[1].nested = 2
ary[2] = 3
EOT
  end

  it 'can be array like (first level only), so puts still works' do
    expect(settings).to respond_to :to_ary
    expect(settings.to_ary).to eq [[:foo, settings.foo]]
  end

  it 'raises exception if expected attribute is missing' do
    expect { settings.nix }.to raise_error(ComplexConfig::AttributeMissing)
  end

  it 'can be checked for set attributes' do
    expect(settings.foo.attribute_set?(:bar)).to eq true
    expect(settings.foo.bar?).to be_truthy
    expect(settings.foo.attribute_set?(:baz)).to eq false
    expect(settings.foo.baz?).to be_falsy
  end

  it 'handles arrays correctly' do
    settings = ComplexConfig::Settings[ary: [ 1, { hsh: 2 }, 3 ]]
    expect(settings.to_h).to eq(ary: [ 1, { hsh: 2 }, 3 ])
  end

  it 'returns zip if it was set' do
    settings = ComplexConfig::Settings[zip: 'a string']
    expect(settings.zip).to eq 'a string'
  end

  it 'zips the hash if zip was not set' do
    settings = ComplexConfig::Settings[not_zip: 'a string']
    expect(settings.zip([1])).to eq [ [ [ :not_zip, 'a string' ], 1 ] ]
  end
end

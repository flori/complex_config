require 'spec_helper'

RSpec.describe ComplexConfig::Settings do
  before do
    # Disable all plugins for this spec b/c they interfere with how rspec works
    allow(ComplexConfig::Provider.instance).to receive(:plugins).and_return([])
  end

  around do |example|
    old_locale, ENV['LOCAL'] = 'en_US.UTF-8', ENV['LANG']
    example.run
  ensure
    ENV['LOCAL'] = old_locale
  end

  let :settings do
    obj = described_class[
      foo: {
        bar: {
          baz: true
        },
        nix: nil,
        qux: 'quux',
      }
    ]
    obj.name_prefix = 'root'
    obj
  end

  it 'can be initialized with a hash' do
    s = described_class.new(foo: 'bar')
    expect(s.foo).to eq 'bar'
  end

  it 'can be duped and changed' do
    s = described_class.new(foo: 'bar')
    t = s.dup
    expect(s.foo).to eq 'bar'
    t.foo = 'baz'
    expect(s.foo).to eq 'bar'
    expect(t.foo).to eq 'baz'
  end

  it 'can set its attributes' do
    expect {
      settings.blub = 'blub'
    }.to change {
      settings.blub?
    }.from(nil).to('blub')
  end

  it 'has a size' do
    expect(settings.size).to eq 1
  end

  it 'can be empty' do
    expect(described_class.new).to be_empty
  end

  it 'can set its attributes via index method' do
    expect {
      settings['blub'] = 'blub'
    }.to change {
      settings.blub?
    }.from(nil).to('blub')
  end

  it "can return an attribute's value" do
    expect(settings.foo.bar.baz).to eq true
  end

  it 'can display its attribute_names' do
    expect(settings.foo.attribute_names).to eq %i[ bar nix qux ]
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
    expect(settings.foo.to_h).to eq(bar: { baz: true }, nix: nil, qux: 'quux')
  end

  it 'can return a hash with pathes as keys' do
    expect(settings.pathes(path_sep: ?:)).to eq(
      'root:foo:bar:baz' => true,
      'root:foo:nix'     => nil,
      'root:foo:qux'     => "quux",
    )
  end

  it 'can be listed as string' do
    expect(settings.attributes_list(pair_sep: ' → ', path_sep: ?/)).to eq <<~EOT
      root/foo/bar/baz → true
      root/foo/nix → nil
      root/foo/qux → "quux"
    EOT
  end

  it 'responds with class name if #to_s is called on empty settigs' do
    expect(described_class.new.to_s).to eq described_class.name
  end

  it 'can be listesd as a string if it has arrays' do
    settings[:ary] = described_class[ [ 1, { nested: 2 }, 3 ] ]
    expect(settings.attributes_list).to eq <<~EOT
      root.foo.bar.baz = true
      root.foo.nix = nil
      root.foo.qux = "quux"
      root.ary[0] = 1
      root.ary[1].nested = 2
      root.ary[2] = 3
    EOT
  end

  it 'can be represented as tree' do
    settings[:ary] = described_class[ [ 1, { nested: 2 }, 3 ] ]
    expect(settings.to_tree.to_s).to eq <<~EOT.chomp
      root
      ├─ foo
      │  ├─ bar
      │  │  └─ baz = true
      │  ├─ nix = nil
      │  └─ qux = "quux"
      └─ ary
         ├─ 1
         ├─ 1
         │  └─ nested = 2
         └─ 3
    EOT
  end

  it 'can be pretty printed with utf8' do
    q = double
    expect(q).to receive(:text).with(<<~EOT.chomp)
      root
      └─ foo
         ├─ bar
         │  └─ baz = true
         ├─ nix = nil
         └─ qux = "quux"
    EOT
    settings.pretty_print(q)
  end

  it 'can be pretty printed with ASCII7' do
    q = double
    expect(q).to receive(:text).with(<<~EOT.chomp)
      root
      `- foo
         +- bar
         |  `- baz = true
         +- nix = nil
         `- qux = "quux"
    EOT
    ENV['LANG'] = 'de_DE.ISO8859-15'
    settings.pretty_print(q)
  end

  it 'can be converted into YAML' do
    expect(settings.to_yaml).to eq <<EOT
---
:foo:
  :bar:
    :baz: true
  :nix:
  :qux: quux
EOT
  end

  it 'can be converted into JSON' do
    expect(settings.to_json).to eq '{"foo":{"bar":{"baz":true},"nix":null,"qux":"quux"}}'
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

  it 'can trigger exception on attribute get' do
    expect(settings.foo.attribute_get!(:bar)).to be_truthy
    expect { settings.foo.attribute_get!(:baz) }.to raise_error ComplexConfig::AttributeMissing
  end

  it 'handles arrays correctly' do
    settings = described_class[ary: [ 1, { hsh: 2 }, 3 ]]
    expect(settings.to_h).to eq(ary: [ 1, { hsh: 2 }, 3 ])
  end

  it 'returns zip if it was set' do
    settings = described_class[zip: 'a string']
    expect(settings.zip).to eq 'a string'
  end

  it 'can be replaced for testing' do
    result = settings.foo.replace_attributes(replaced: true)
    expect(settings.foo.replaced).to eq true
    expect(settings.foo).to eq result
  end
end

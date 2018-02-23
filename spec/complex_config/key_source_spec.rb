require 'spec_helper'

RSpec.describe ComplexConfig::KeySource do
  it 'should provide key from pathname' do
    ks = described_class.new(pathname: asset('with-key-file.yml'))
    expect(ks.key).to eq '90ec1139596f9dfdb51e72277735ce9a'
  end

  it 'should provide key from env_var' do
    ENV['THE_KEY'] = '41424344'
    ks = described_class.new(env_var: 'THE_KEY')
    expect(ks.key_bytes).to eq "ABCD"
    ENV['THE_KEY'] = nil
  end

  it 'should provide key from var' do
    ks = described_class.new(var: 'deadbeef')
    expect(ks.key).to eq 'deadbeef'
  end

  it 'should provide key from master_key_pathname' do
    ks = described_class.new(master_key_pathname: asset('master.key'))
    expect(ks.key).to eq '90ec1139596f9dfdb51e72277735ce9a'
  end

  it 'can return key as bytes' do
    ks = described_class.new(var: '41424344')
    expect(ks.key_bytes).to eq "ABCD"
  end

  it 'cannot use more than one setting' do
    expect {
      described_class.new(var: 'deadbeef', env_var: 'FOO')
    }.to raise_error ArgumentError
  end
end

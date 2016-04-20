 require 'spec_helper'

describe HawatelTlb::Mode::Weighted do
  let(:client) { HawatelTlb::Client.new }

  it 'Find host with highest weight' do
    client.add({:host => 'example.com', :port => 80, :weight => 0})
    client.add({:host => 'wp.pl', :port => 80, :weight => 5})
    client.add({:host => 'onet.pl', :port => 80, :weight => 3})
    client.configure({:mode => 'weighted'})
    stat = client.node
    expect(stat[:host]).to eq('wp.pl')
    expect(stat[:port]).to eq(80)
  end

  it 'Two hosts has equal range of weight ' do
    client.add({:host => 'example.com', :port => 80, :weight => 0})
    client.add({:host => 'wp.pl', :port => 80, :weight => 5})
    client.add({:host => 'onet.pl', :port => 80, :weight => 5})
    client.configure({:mode => 'weighted'})
    stat = client.node
    expect(stat[:host]).to eq('wp.pl')
    expect(stat[:port]).to eq(80)
  end

  it 'All hosts are disable' do
    client.add({:host => 'example.com', :port => 80, :weight => 0, :state => 'disable'})
    client.add({:host => 'wp.pl', :port => 80, :weight => 5, :state => 'disable'})
    client.configure({:mode => 'weighted'})
    expect(client.node).to eq(false)
  end

  it 'All hosts are offline' do
    client.add({:host => 'example.com', :port => 1, :weight => 0})
    client.add({:host => 'wp.pl', :port => 1, :weight => 5})
    client.configure({:mode => 'weighted'})
    expect(client.node).to eq(false)
  end

end
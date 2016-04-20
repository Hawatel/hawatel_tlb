require 'spec_helper'

describe HawatelTlb::Mode::RoundRobin do
  let(:client) { HawatelTlb::Client.new }

  it 'Fastest respond server' do
    client.add({:host => 'example.com', :port => 443, :weight => 0})
    client.add({:host => 'google.com', :port => 443, :weight => 0})
    client.add({:host => 'hawatel.com', :port => 443, :weight => 0})
    client.configure({:mode => 'fastest', :interval => 5})
    expect(client.node[:host]).to be_a_kind_of(String)
    expect(client.node[:port]).to be_a_kind_of(Fixnum)
  end

  it 'Lack of statistics for one node' do
    client.add({:host => 'example.com', :port => 443, :weight => 0})
    client.configure({:mode => 'fastest'})
    client.add({:host => 'google.com', :port => 443, :weight => 0})
    expect(client.node[:host]).to eq('example.com')
    expect(client.node[:port]).to eq(443)
  end


  it 'Available only one node' do
    client.add({:host => 'example.com', :port => 443, :weight => 0,})
    client.add({:host => 'thisdomainshouldexist2.com', :port => 443, :weight => 0 })
    client.configure({:mode => 'fastest'})
    expect(client.node[:host]).to eq('example.com')
    expect(client.node[:port]).to eq(443)
  end

  it 'All nodes are disabled' do
    client.add({:host => 'example.com', :port => 443, :weight => 0, :state => 'disable'})
    client.add({:host => 'google.com', :port => 443, :weight => 0, :state => 'disable'})
    client.configure({:mode => 'fastest'})
    expect(client.node).to eq(false)
  end

  it 'All nodes are offline' do
    client.add({:host => 'thisdomainshouldexist1.com', :port => 443, :weight => 0,})
    client.add({:host => 'thisdomainshouldexist2.com', :port => 443, :weight => 0 })
    client.configure({:mode => 'fastest'})
    expect(client.node).to eq(false)
  end

end
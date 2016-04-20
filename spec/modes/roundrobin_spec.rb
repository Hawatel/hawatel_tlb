require 'spec_helper'

describe HawatelTlb::Mode::RoundRobin do
  let(:client) { HawatelTlb::Client.new }

  it 'all nodes are enabled' do
    client.add({:host => 'example.com', :port => 443, :weight => 0})
    client.add({:host => 'example2.com', :port => 443, :weight => 0})
    client.configure({:mode => 'roundrobin'})
    expect(client.node[:host]).to eq('example.com')
  end

  it 'all nodes are disabled' do
    client.add({:host => 'example.com', :port => 443, :weight => 0, :state => 'disable'})
    client.add({:host => 'example2.com', :port => 443, :weight => 0, :state => 'disable'})
    client.configure({:mode => 'roundrobin'})
    expect(client.node).to eq(false)
  end

  it 'overloop nodes' do
    client.add({:host => 'example.com', :port => 443, :weight => 0, :state => 'enable'})
    client.add({:host => 'example2.com', :port => 443, :weight => 0, :state => 'enable'})
    client.add({:host => 'github.com', :port => 80, :weight => 0, :state => 'enable'})
    client.configure({:mode => 'roundrobin'})
    ip_1 = client.node[:host]
    ip_2 = client.node[:host]
    ip_3 = client.node[:host]
    ip_4 = client.node[:host]
    expect(ip_1).to eq('example.com')
    expect(ip_2).to eq('example2.com')
    expect(ip_3).to eq('github.com')
    expect(ip_4).to eq('example.com')
  end

  it 'all nodes are offline' do
    client.add({:host => 'thisdomainshouldexist1.com', :port => 443, :weight => 0,})
    client.add({:host => 'thisdomainshouldexist2.com', :port => 443, :weight => 0 })
    client.configure({:mode => 'roundrobin'})
    expect(client.node).to eq(false)
  end

end
require 'spec_helper'

describe HawatelTlb::Client do

 let(:client) { HawatelTlb::Client.new }


 describe 'Validate_host_settings?' do

   it 'Add valid host' do
     result = client.add({:host => '8.8.8.3', :port => 443, :weight => 0})
     expect(result).to eq('success')
   end

   it 'Add host with invalid ip' do
    result = client.add({:host => '8.256.2.3', :port => 80, :weight => 0})
    expect(result).to eq('incorrect host name or ip address, ')
   end

   it 'Add host with invalid port number' do
    result = client.add({:host => '8.3.2.3', :port => 0, :weight => 0})
    expect(result).to eq('incorrect port number, ')
   end

   it 'Add host with invalid domainame' do
    result = client.add({:host => 'example.23sd', :port => 80, :weight => 0})
    expect(result).to eq('incorrect host name or ip address, ')
   end

   it 'Duplicate host' do
     client.add({:host => 'example.com', :port => 80, :weight => 0})
     result_2 = client.add({:host => 'example.com', :port => 80, :weight => 0})
     expect(result_2).to eq('host with the same configuration already exists in the group, ')
   end

 end

 describe 'Delete host' do

   it 'Delete non exist id' do
     result = client.del(22)
     expect(result).to eq('invalid host id')
   end

   it 'String instead Fixnumer' do
     result = client.del('asdasd')
     expect(result).to eq('invalid value')
   end

   it 'Delete host' do
     id = client.add({:host => 'example.com', :port => 80, :weight => 0})
     expect(client.del(1)).to eq('host successful deleted')
   end

 end


 describe 'Configure group' do

   it 'Configure' do
     result = client.configure({:mode => 'RR'})
     expect(result).to eq('invalid mode')
   end

 end

 it "Get current list" do
   client.add({:host => 'example.com', :port => 443, :weight => 0})
   client.add({:host => 'example2.com', :port => 443, :weight => 0})
   client.add({:host => 'example3.com', :port => 443, :weight => 0})
   expect(client.list[0][:id]).to eq(1)
   expect(client.list[0][:host]).to eq('example.com')
   expect(client.list[0][:port]).to eq(443)
   expect(client.list[0][:weight]).to eq(0)
 end
end

require 'spec_helper'

describe HawatelTlb::Mode::DynamicRatio do

  let(:client) { HawatelTlb::Client.new }
  before do
    stub_const("HawatelTlb::Mode::DynamicRatio::RECALC_WEIGHT_INTERVAL", 1)
  end

  context 'dynamic weights' do
    let(:loop_count) { 1000 }
    it 'weight is not in init state' do
      setup_dynamicratio_mode
      exec_node_method(loop_count)
      verify_weights(client.list)
      verify_weights(client.list)

    end
  end

  private

  def verify_weights(nodes)
    nodes.each do |node|
      expect(node.weight).to be > 1
    end
  end

  def setup_dynamicratio_mode
    client.add({:host => 'example.com', :port => 80})
    client.add({:host => 'example2.com', :port => 80})
    client.add({:host => 'example3.com', :port => 80})
    client.configure(:mode => 'dynamicratio')
    client.mode.debug = 0
  end

  def exec_node_method(count)
    (0..count-1).each do
      client.node
    end
  end

end
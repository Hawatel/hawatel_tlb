require 'spec_helper'

describe HawatelTlb::Mode::Ratio do

  let(:client) { HawatelTlb::Client.new }

  context "the most important node" do
    let(:loop_count) { 1000 }

    it "the first one" do
      setup_ratio_mode(2,1,1)
      exec_node_method(loop_count)

      nodes = client.list

      expect(nodes[0].ratio[:traffic]).to eq(500)
      expect(nodes[1].ratio[:traffic]).to eq(250)
      expect(nodes[2].ratio[:traffic]).to eq(250)

      expect(sum_traffic(nodes)).to eq(loop_count)
    end

    it "the second one" do
      setup_ratio_mode(2,40,10)
      exec_node_method(loop_count)

      nodes = client.list

      expect(nodes[0].ratio[:traffic]).to eq(39)
      expect(nodes[1].ratio[:traffic]).to eq(769)
      expect(nodes[2].ratio[:traffic]).to eq(192)

      expect(sum_traffic(nodes)).to eq(loop_count)
    end

    it "the third one" do
      setup_ratio_mode(0,60,1000)
      exec_node_method(loop_count)

      nodes = client.list

      expect(nodes[0].ratio[:traffic]).to eq(1)
      expect(nodes[1].ratio[:traffic]).to eq(57)
      expect(nodes[2].ratio[:traffic]).to eq(942)

      expect(sum_traffic(nodes)).to eq(loop_count)
    end
  end

  private

  def setup_ratio_mode(w1, w2, w3)
    client.add({:host => 'example.com', :port => 80, :weight => w1})
    client.add({:host => 'example2.com', :port => 80, :weight => w2})
    client.add({:host => 'example3.com', :port => 80, :weight => w3})
    client.configure(:mode => 'ratio')
    client.mode.debug = 0
  end

  def exec_node_method(count)
    (0..count-1).each do
      client.node
    end
  end

  def sum_traffic(nodes)
    traffic = 0
    nodes.each do |node|
      traffic += node.ratio[:traffic]
    end
    traffic
  end

end
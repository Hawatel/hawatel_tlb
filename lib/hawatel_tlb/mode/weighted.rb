module HawatelTlb::Mode
  class Weighted

    # number of elements stored in history array
    HISTORY_SIZE = 3

    def initialize(group)
      @group   = group
      @history = Array.new
      @counter = 0
    end

    # Refresh group table after delete or add host
    #
    # @param group [Array<Hash>]
    def refresh(group)
      @group = group
    end

    #
    # @return [Hash] hostname/ip address and port number
    def node

      # push nodes statistics to history array
      if @counter < HISTORY_SIZE
        @history[@counter] = @group.dup
        @counter += 1
      else
        @counter = 0
        @history[@counter] = @group.dup
      end

      # build array with only
      current_online = Array.new
      @group.each do |node|
        current_online.push(node.id) if node.state == 'enable' && node.status[:state] == 'online'
      end

      # there is no any available node
      return false if current_online.empty?

      # there is only one available node
      return find_node(current_online[0]) if current_online.size == 1

      # there is more that one nodes - choose the most reliable node
      nodes_reliability = Array.new
      @history.each do |round|
        round.each do |node|
          if node.state == 'enable' && node.status[:state] == 'online'
            nodes_reliability[node.id] =  Hash.new if nodes_reliability[node.id].nil?
            nodes_reliability[node.id][:online_count] = 0 if nodes_reliability[node.id][:online_count].nil?
            nodes_reliability[node.id][:online_count] += 1
          end
        end
      end

      # choose only top nodes with equal online state
      top_nodes_by_state = Array.new
      top_value = 0
      sort_by_state(nodes_reliability).each do |node|
        top_value = node[:online_count] if top_value == 0
        if node[:online_count] == top_value
          node_param = @group.select {|item| item[:id] == node[:hostid]}
          top_nodes_by_state << node_param
        else
          break
        end
      end

      # there is only one node with highest online count
      return {:host => top_nodes_by_state[0][:host], port => top_nodes_by_state[0][:port]} if top_nodes_by_state.size == 1

      # find node with highest weight
      nodes = sort_by_weight(top_nodes_by_state)
      return {:host => nodes[0][0].host, :port => nodes[0][0].port}
    end

    private
    # return node hostname and port based on node id
    def find_node(node_id)
      node_param = @group.select {|node| node[:id] == node_id}
      {:host => node_param[0].host, :port => node_param[0].port}
    end

    # sort nodes by online counter
    def sort_by_state(nodes)
      sorted_nodes = Array.new
      nodes.each_with_index do |node, index|
        next if node.nil?
        node[:hostid] = index
        sorted_nodes.push(node)
      end
      sorted_nodes.sort_by { |node| node[:online_count]}.reverse!
    end

    # sort by average weight
    def sort_by_weight(nodes)
      nodes.sort_by { |node| node[0].weight }.reverse!
    end

  end
end
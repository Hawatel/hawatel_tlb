module HawatelTlb::Mode
  class Fastest

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

    # Calculate base on fastest algorithm
    # Algorithm based on history statistics about respond time and 'online' states (flapping detection)
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

      current_online = Array.new
      @group.each do |node|
        current_online.push(node.id) if node.state == 'enable' && node.status[:state] == 'online'
      end

      # there is no any available node
      return false if current_online.empty?

      # there is only one available node
      return find_node(current_online[0]) if current_online.size == 1

      # there are more that one online nodes
      nodes_sorted_stats = sort_by_state(average_respond_time(current_online))

      # choose only top nodes with equal online state
      top_nodes_by_state = Array.new
      top_value = 0
      nodes_sorted_stats.each do |node|
        top_value = node[:online_count] if top_value == 0
        if node[:online_count] == top_value
          top_nodes_by_state.push(node)
        else
          break
        end
      end

      # there is only one node with highest online count
      return find_node(top_nodes_by_state[0][:id]) if top_nodes_by_state.size == 1

      # there are more with top
      top_nodes_by_respond = sort_by_respond(top_nodes_by_state)
      find_node(top_nodes_by_respond[0][:id])
    end

    private
    # sort decedent nodes by online counter
    def sort_by_state(nodes)
      sorted_nodes = Array.new
      nodes.each_with_index do |node, index|
        next if node.nil?
        node[:id] = index
        sorted_nodes.push(node)
      end
      sorted_nodes.sort_by { |node| node[:online_count]}.reverse!
    end

    # sort by average respond time
    def sort_by_respond(nodes)
      nodes.sort_by { |node| node[:avg_respond_time]}
    end

    # return node hostname and port based on node id
    def find_node(node_id)
      node_param = @group.select {|node| node[:id] == node_id}
      {:host => node_param[0].host, :port => node_param[0].port}
    end

    # calculate average respond time time for online nodes
    def average_respond_time(current_online)
      stats = Array.new
      @history.each do |round|
        round.each do |node|
          if node.status[:state] == 'online' && current_online.include?(node.id)
            stats[node.id] = Hash.new if !stats[node.id].is_a?(Hash)
            !stats[node.id][:online_count] ? stats[node.id][:online_count] = 1 : stats[node.id][:online_count] += 1
            !stats[node.id][:sum_respond_time] ?
                stats[node.id][:sum_respond_time] = node.status[:respond_time] :
                stats[node.id][:sum_respond_time] += node.status[:respond_time]
            !stats[node.id][:avg_respond_time] ?
                stats[node.id][:avg_respond_time] = node.status[:respond_time] :
                stats[node.id][:avg_respond_time] = stats[node.id][:sum_respond_time] / stats[node.id][:online_count]
          end
        end
      end
      return stats
    end
  end
end

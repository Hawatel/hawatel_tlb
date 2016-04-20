module HawatelTlb::Mode
  ##
  # = Ratio algorithm
  #
  # Thease are static load balancing algorithm based on ratio weights.
  # Algorithm explanation:
  # 1. divide the amount of traffic (requests) sent to each server by weight (configured in the Client)
  # 2. Sort by ratio (result from 1. point) from smallest to largest
  # 3. Get node with smallest ratio
  # If you want to see how it works you can set client.mode.debug to 1 and run ratio_spec.rb.
  # @!attribute [rw] debug
  class Ratio
    attr_accessor :debug

    def initialize(group)
      @traffic = 0
      @debug = 0

      group.each do |node|
        node.ratio = Hash.new
        node.ratio[:traffic] = 0
        node.ratio[:value] = 0

        node.weight = 1 if node.weight.to_i < 1
      end

      @group = group
    end

    # Refresh group table after delete or add host
    #
    # @param group [Array<Hash>]
    def refresh(group)
      @group = group
    end

    # Description
    # @param name [Type] description
    # @option name [Type] :opt description
    # @example
    #   mode = Ratio.new(nodes)
    #   p mode.node
    # @return [Hash] :host and :port
    def node
      node = get_right_node
      return {:host => node.host, :port => node.port} if node
      false
    end

    private

    def get_right_node
      nodes = sort_nodes_by_ratio_asc
      node = get_first_online_node(nodes)
      debug_log(nodes)

      if node
        set_ratio(node)
        return node
      else
        false
      end
    end

    def get_first_online_node(nodes)
      nodes.each do |node|
        return node if node.status[:state] == 'online' && node.state == 'enable'
      end
      false
    end

    def sort_nodes_by_ratio_asc
      @group.sort_by {|node| node.ratio[:value]}
    end

    def set_ratio(node)
      @traffic += 1
      node.ratio[:traffic] += 1
      node.ratio[:value] = calc_ratio(node.ratio[:traffic], node.weight)
    end

    def calc_ratio(traffic, weight)
      if weight.zero?
        0
      else
        traffic.to_f / weight.to_f
      end
    end

    def debug_log(nodes)
      if @debug > 0
        puts ">> request: #{@traffic} | selected #{nodes[0].host}"
        nodes.each do |node|
          puts "\t" "#{node.host} - ratio: #{node.ratio}, weight: #{node.weight}\n"
        end
        puts "------------------------------------------------------------"
      end
    end

  end
end
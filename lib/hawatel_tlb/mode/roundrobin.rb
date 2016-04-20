module HawatelTlb
  module Mode

    ##
    # = Overview
    #
    # Details
    #
    # @!attribute [rw] name
    #   @return [Type] description
    class RoundRobin

      def initialize(group)
        @group = group
        @round = Array.new
      end

      # Refresh group table after delete or add host
      #
      # @param group [Array<Hash>]
      def refresh(group)
        @group = group
      end

      # Return ip address based on Round Robin algorithm
      #
      # @return [Hash] hostname/ip address and port number
      def node
        counter    = 0
        first_item = ''
        @group.each do |node|
          if !node.status.empty?
            if node.status[:state] == 'online' && node.state == 'enable'
              first_item = {:host => node.host, :port => node.port} if counter == 0
              if !@round.include?(node.id)
                @round.push(node.id)
                return {:host => node.host, :port => node.port}
              end
              counter += 1
            end
          end
        end
        @round = Array.new
        return first_item if !first_item.empty?
        false
      end

    end
  end
end
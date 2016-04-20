module HawatelTlb::Mode
  ##
  # = Dynamic Ratio algorithm
  #
  # Thease are dynamic load balancing algorithm based on dynamic ratio weights.
  # Algorithm explanation:
  # 1. Weight for each node is setting up by following formula:
  #    100 - (respond_time / sum_respond_time) * 100
  #    Weights are refreshing once per minute
  # 2. divide the amount of traffic (requests) sent to each server by weight (configured in the Client)
  # 3. Sort by ratio (result from 1. point) from smallest to largest
  # 4. Get node with smallest ratio
  # If you want to see how it works you can set client.mode.debug to 1 and run dynamicratio_spec.rb.
  # @!attribute [rw] debug
  #   0: enable, 1: disable
  class DynamicRatio < Ratio
    attr_accessor :recalc_interval

    RECALC_WEIGHT_INTERVAL = 10

    def initialize(group)
      super(group)

      @recalc_interval = RECALC_WEIGHT_INTERVAL
      @dynamic_weight = 1
      set_weights
      thread_start
    end

    # Destroy thread
    def destroy
      @dynamic_weight = 0
    end

    private

    def sum_respond_time
      sum = 0
      @group.each do |node|
        if node.status[:state] == 'online' && node.state == 'enable'
          sum += node.status[:respond_time]
        end
      end
      sum
    end

    def set_weights
      sum = sum_respond_time
      @group.each do |node|
        if node.status[:state] == 'online' && node.state == 'enable'
          node.weight = 100 - ((node.status[:respond_time] / sum) * 100).to_i if !sum.zero?
        end
      end
    end

    def thread_start
      @thr = Thread.new{
        while(@dynamic_weight == 1)
          sleep(RECALC_WEIGHT_INTERVAL)
          thread_heartbeat
          set_weights
        end
      }
    rescue => e
      puts "Exception: #{e.inspect}"
    end

    def thread_heartbeat
      if @debug > 0
        puts "#{Time.now} thread hearbeat #{Thread.current.object_id}"
      end
    end

  end
end
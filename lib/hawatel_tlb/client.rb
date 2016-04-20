require 'hawatel_tlb/watchdog'
require 'hawatel_tlb/mode'
require 'ostruct'

module HawatelTlb
  class Client
    include HawatelTlb::WatchDog

    attr_reader :group, :mode, :interval

    WORKING_MODE    = {
        'dynamicratio' => Mode::DynamicRatio,
        'roundrobin' => Mode::RoundRobin,
        'fastest' => Mode::Fastest,
        'ratio' => Mode::Ratio,
        'weighted' => Mode::Weighted
    }
    DEFAULT_STATE     = 'enable'
    DEFAULT_PORT      = 80
    DEFAULT_WEIGHT    = 1
    DEFAULT_TIMEOUT   = 5
    DEFAULT_INTERVAL  = 5

    def initialize
      @group    = Array.new
      @interval = DEFAULT_INTERVAL
      watchdog_thread()
    end

    # Add host to TLB group
    #
    # @param args [Hash]
    # @option args [String]  :host hostname or ip address
    # @option args [Integer] :port port number
    # @option args [Integer] :timeout default 5s.
    # @option args [String]  :state Available options: enable(default), disable.
    # @option args [Integer] :wight priority of host, higher value is equal lower priority
    # @example
    #   client.add({:value => 'example'})
    #
    #
    # @return [Integer]
    def add(args)
      host    = args[:host]
      port    = args[:port]    || DEFAULT_PORT
      weight  = args[:weight]  || DEFAULT_WEIGHT
      timeout = args[:timeout] || DEFAULT_TIMEOUT
      state   = args[:state]   || DEFAULT_STATE

      status = validate_host_settings({:host => host, :port => port, :weight => weight, :timeout => timeout,
                                       :state => state})
      if status == 'success'
        host_cfg = OpenStruct.new(:id => host_id.to_i, :host => host, :port => port, :weight => weight,
                                  :timeout => timeout, :state => state, :status => {:time => 0, :state => 'offline',
                                                                                    :respond_time => 0})
        @group.push(host_cfg)
      end
      @mode.refresh(@group) if @mode
      return status
    end

   # Delete host from TLB group
   #
   # @param id [Integer] host id
   # @example
   #   client.del(2)
   #
   # @return [String]
    def del(id)
      if id.is_a?(Fixnum)
        if @group[id-1]
          @group.delete(id-1)
          @mode.refresh(@group) if @mode
          return 'host successful deleted'
        else
          return 'invalid host id'
        end
      else
        'invalid value'
      end
    end


    # Return hosts list
    #
    # @example
    #   client.add({:host => 'example.com', :port => '80', weight => '5'})
    #   client.list
    #
    # @return [Array<String>]
    def list
      return @group
    end

    # Set settings for group
    #
    # @param args [Hash]
    # @option args [String] :mode  failover, roundrobin
    # @example
    #   client.configure({:mode => 'roundrobin'})
    #
    # @return [Integer]
    def configure(args)
      if @group[0]
        watcher if @group[0].status[:time] == 0
      end

      mode = args[:mode] || 'roundrobin'
      @interval if args[:interval]
      return 'invalid mode' if !WORKING_MODE.key?(mode)
      if @mode
        @mode.destroy if @mode.respond_to?(:destroy)
        @mode = nil
      else
        @mode = nil
      end
      @mode = WORKING_MODE[mode].new(@group)
    end


    # Description
    #
    # @param args [Hash]
    # @option args [String] :value description
    # @example
    #   counte({:value => 'example'})
    #
    #
    # @return [Integer]
    def node
      return @mode.node if @mode
      false
    end

    # Description
    #
    # @param args [Hash]
    # @option args [String] :value description
    # @example
    #   counte({:value => 'example'})
    #
    #
    # @return [Integer]
    def status
      @group.each do |node|
      end
    end

    private

    # start watcher, thread responsible for online monitoring
    def watchdog_thread
      @thr = Thread.new {
        while(true)
          watcher
          sleep(@interval)
        end
      }
      rescue
        false
    end

    # Validate host settings
    def validate_host_settings(args)
      msg = ''
      msg << 'host with the same configuration already exists in the group, ' if !validate_list?(args)
      msg << 'incorrect host name or ip address, ' if !(valid_v4?(args[:host]) || valid_domain?(args[:host]))
      msg << 'incorrect port number, ' if !valid_port?(args[:port])
      msg << 'incorrect weight value, ' if !args[:weight].is_a?(Fixnum)
      msg << 'incorrect timeout value, ' if !args[:timeout].is_a?(Fixnum)
      msg.empty? ? 'success' : msg
    end

    # Check if specified host, with the same port dosen't already exist in group
    def validate_list?(args)
      @group.each do |item|
        return false if item[:host] == args[:host] && item[:port] == args[:port]
      end
      return true
    end

    # validate ipv4
    def valid_v4?(addr)
      if /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/ =~ addr
        return $~.captures.all? {|i| i.to_i < 256}
      end
    end

    # Validate domainname
    def valid_domain?(host)
      true if /([a-z]|[0-9])*\.[a-z]{2,5}$/ =~ host
    end

    # Validate port
    def valid_port?(port)
      if port.is_a?(Fixnum)
        true if port <= 65535 && port > 0
      end
    end

    # Generate host id
    def host_id
      return @group.length + 1
    end

  end
end
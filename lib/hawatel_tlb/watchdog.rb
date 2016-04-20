require 'socket'
require 'timeout'
require 'bigdecimal'

module HawatelTlb
  module WatchDog

      # Check node status
      #
      def watcher
        @group.each do |node|
          if node.state == 'enable'
            start = Time.now()
            port_open?(node) ? port_state = 'online' : port_state = 'offline'
            stop  = Time.now() - start
            node.status = {:time => Time.now.to_i, :state => port_state, :respond_time => stop.round(4)}
          end
        end
      end

      private
      # Check if port is open
      #
      def port_open?(node)
        Timeout::timeout(node.timeout) do
          begin
            TCPSocket.new(node.host, node.port).close
            true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            false
          end
        end
      rescue Timeout::Error, SocketError
        false
      end

  end
end
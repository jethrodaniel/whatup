# frozen_string_literal: true

require 'socket'

module Whatup
  module Client
    class Client
      include Thor::Shell

      def initialize ip:, port:
        @dest = {
          ip: ip,
          port: port,
          address: "#{@ip}:#{@port}"
        }
      end

      def connect
        say "Connecting to #{@dest[:ip]}:#{@dest[:port]} ..."

        @socket = TCPSocket.open @dest[:ip], @dest[:port]

        @request = request!
        @response = listen!

        [@request, @response].each &:join
      rescue SignalException
        say 'Exiting ...', :red
        exit
      end

      def request!
        puts 'Please enter your username to establish a connection...'
        begin
          Thread.new do
            loop do
              message = $stdin.gets.chomp
              @socket.puts message
            end
          end
        rescue IOError => e
          puts e.message
          # e.backtrace
          @socket.close
        end
      end

      def listen!
        Thread.new do
          loop do
            response = @socket.gets.chomp
            puts response.to_s
            @socket.close if response.eql? 'quit'
          end
        end
      rescue IOError => e
        puts e.message
        # e.backtrace
        @socket.close
      end
    end
  end
end

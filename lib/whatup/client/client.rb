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
        Thread.new do
          loop do
            print '> '
            input = $stdin.gets&.chomp
            exit if input.nil?
            @socket.puts input
          end
        end
      rescue IOError => e
        puts e.message
        @socket.close
      end

      def listen!
        Thread.new do
          loop do
            response = @socket.gets&.chomp
            puts response unless response.nil?
          end
        end
      rescue IOError => e
        puts e.message
        @socket.close
      end
    end
  end
end

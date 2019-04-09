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

        puts 'Please enter your username to establish a connection...'
        @request = request!
        @response = listen!

        [@request, @response].each &:join
      rescue SignalException
        say 'Exiting ...', :red
        exit
      end

      private

      # Loop and send all input to the server
      def request!
        Thread.new do
          loop do
            input = Readline.readline '~> ', true
            next if input.nil?

            @socket.puts input
          end
        end
      rescue IOError => e
        puts e.message
        @socket.close
      end

      # Continually listen to the server, and print anything received
      def listen!
        Thread.new do
          loop do
            response = @socket.gets&.chomp

            if response == 'END'
              puts
              kill_all_but_current_thread!
              exit
            end

            puts response # unless response.nil?
          end
        end
      rescue IOError => e
        puts e.message
        @socket.close
      end

      def kill_all_but_current_thread!
        Thread.list.each do |thread|
          thread.exit unless thread == Thread.current
        end
      end
    end
  end
end

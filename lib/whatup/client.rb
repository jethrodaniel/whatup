# frozen_string_literal: true

require 'socket'

module Whatup
  class Client
    include Thor::Shell

    def initialize ip: 'localhost', port: 9_001
      @dest = {
        ip: ip,
        port: port,
        address: "#{@ip}:#{@port}"
      }
    end

    def start
      say "Connecting to #{@dest[:ip]}:#{@dest[:port]} ..."

      socket = TCPSocket.open @dest[:ip], @dest[:port]

      loop do
        while message = socket.gets
          puts message
        end
      end
    rescue SignalException
      say 'Exiting ...', :red
      exit
    end
  end
end

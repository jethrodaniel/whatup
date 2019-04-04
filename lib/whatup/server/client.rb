# frozen_string_literal: true

module Whatup
  module Server
    class Client
      attr_reader :id, :name
      attr_accessor *%i[socket room]

      def initialize id:, name:, socket:
        @id = id
        @name = name
        @socket = socket
        @room = nil
      end

      def puts msg
        socket.puts msg
      end

      def gets
        socket.gets
      end

      def input!
        loop while (msg = gets).blank?
        msg.chomp
      end

      def room?
        !room.nil?
      end
      alias chatting? room?

      def status
        "#{name}" \
        "#{chatting? ? " (#{@room.name})" : ''}"
      end

      def broadcast msg
        @room.clients.reject { |c| c == self }
             .each { |c| c.puts "#{name}> #{msg}" }
      end

      def leave_room!
        broadcast 'LEFT'
        room.drop_client! self
        @room = nil
      end

      def exit!
        puts "END\n"
        Thread.kill Thread.current
      end
    end
  end
end

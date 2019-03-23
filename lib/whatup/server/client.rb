# frozen_string_literal: true

module Whatup
  module Server
    class Client
      attr_reader :id, :name
      attr_accessor :socket

      def initialize id:, name:, socket:
        @id = id
        @name = name
        @socket = socket
      end

      def puts msg
        @socket.puts msg
      end

      def gets
        @socket.gets
      end
    end
  end
end

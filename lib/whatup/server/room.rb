# frozen_string_literal: true

module Whatup
  module Server
    class Room
      attr_accessor *%i[name clients]

      def initialize name:, clients:
        @name = name
        @clients = clients

        @clients.each { |c| c.room = self }
      end

      def drop_client! client
        @clients = @clients.reject { |c| c == client }
      end

      def broadcast except: nil
        clients = except \
          ? @clients.reject { |c| c == except }
          : @clients

        clients.each { |c| c.puts yield }
      end
    end
  end
end

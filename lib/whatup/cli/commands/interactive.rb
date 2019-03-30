# frozen_string_literal: true

require 'thor'

require 'whatup/client/client'

module Whatup
  module CLI
    # Interactive client commands that are available after connecting
    #
    # This class is run on the server
    class Interactive < Thor
      attr_accessor :server

      # Don't show app name in command help, i.e, instead of
      # `app command desc`, use `command desc`
      def self.banner task, _namespace = false, subcommand = false
        task.formatted_usage(self, false, subcommand).to_s
      end

      desc 'list', 'show all connected clients'
      def list
        say 'All connected clients:'
        @server.clients.each do |c|
          say "#{c.name}#{c.chatting? ? ' (busy chatting)' : ''}"
        end
      end

      desc 'chat [CLIENT]', 'starts a chat with the specified client'
      def chat client
        # @server.
      end

      desc 'exit', "closes a client's connection with the server"
      def exit; end
    end
  end
end

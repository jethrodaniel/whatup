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
        @server.clients.each { |c| say c.name, :green }
      end

      desc 'chat [NAME]', 'starts a chat with the specified client'
      def chat client, name
        # @server.
      end

      desc 'exit', "closes a client's connection with the server"
      def exit; end
    end
  end
end

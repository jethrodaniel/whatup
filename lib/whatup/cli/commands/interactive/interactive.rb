# frozen_string_literal: true

require 'thor'

require 'whatup/client/client'

module Whatup
  module CLI
    # Any methods of class `Whatup::CLI::Interactive` that rely on instance
    # variables should be included here
    COMMANDS = %i[chat list].freeze

    require 'whatup/cli/commands/interactive/setup'

    # Interactive client commands that are available after connecting
    #
    # This class is run on the server
    class Interactive < Thor
      prepend InteractiveSetup

      # Don't show app name in command help, i.e, instead of
      # `app command desc`, use `command desc`
      def self.banner task, _namespace = false, subcommand = false
        task.formatted_usage(self, false, subcommand).to_s
      end

      desc 'list', 'show all connected clients'
      def list
        say 'All connected clients:'
        if @server&.clients.nil?
        end

        @server.clients.each do |c|
          say "#{c.name}#{c.chatting? ? ' (busy chatting)' : ''}"
        end
      end

      desc 'chat [CLIENT]', 'starts a chat with the specified client'
      def chat client
        # @server.clients.each do |c|
        # @server.
      end

      desc 'exit', "closes a client's connection with the server"
      def exit; end
    end
  end
end

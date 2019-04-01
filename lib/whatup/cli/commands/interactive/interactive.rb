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

      attr_accessor *%i[server current_user]

      no_commands do
        # Checks whether a given input string is a valid command
        def self.command? msg
          cmds, opts = parse_input(msg)
          parsed_args = new(cmds, opts).args
          commands.key?(parsed_args.first) || parsed_args.first == 'help'
        end

        # Parses a client's input into a format suitable for Thor commands
        #
        # @param [String] msg - the client's message
        def self.parse_input msg
          # Split user input at the first "option"
          cmds, opts = msg&.split /-|--/, 2

          # Then split each by whitespace
          cmds = cmds&.split(/\s+/)
          opts = opts&.split(/\s+/)

          # `Whatup::CLI::Interactive.new(cmds, opts)` expects arrays, and
          # a final options hash
          cmds = [] if cmds.nil?
          opts = [] if opts.nil?

          [cmds, opts]
        end
      end

      # Don't show app name in command help, i.e, instead of
      # `app command desc`, use `command desc`
      def self.banner task, _namespace = false, subcommand = false
        task.formatted_usage(self, false, subcommand).to_s
      end

      desc 'list', 'Show all connected clients'
      def list
        say 'All connected clients:'

        @server.clients.each do |c|
          say "#{c.name}#{c.chatting? ? ' (busy chatting)' : ''}"
        end
      end

      desc 'chat [NAME]', 'Start chatting with the [NAME] in a new chat room'
      def chat name
        client = @server.clients.select { |c| c.name == name }&.first

        if client.nil?
          @current_user.puts "No client named `#{client.inspect}` found!"
          return
        end

        @current_user.puts "you are #{@current_user}"
        @current_user.puts "trying to talk to: #{client}"
      end

      desc 'exit', "closes a client's connection with the server"
      def exit; end
    end
  end
end

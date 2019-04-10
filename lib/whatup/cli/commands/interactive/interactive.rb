# frozen_string_literal: true

require 'thor'

require 'whatup/client/client'

module Whatup
  module CLI
    # Any methods of class `Whatup::CLI::Interactive` that rely on instance
    # variables should be included here
    COMMANDS = %i[
      room
      list
      exit
      dmlist
      dm
    ].freeze

    require 'whatup/cli/commands/interactive/setup'

    # Interactive client commands that are available after connecting
    #
    # This class is run on the server
    class Interactive < Thor
      prepend InteractiveSetup

      Room = Whatup::Server::Room
      Client = Whatup::Server::Client

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
        @server.clients_except(@current_user).each { |c| say "  #{c.status}" }
        say "* #{@current_user.status}"
      end

      desc 'room [NAME]', 'Create and enter chatroom [NAME]'
      def room name
        if room = Room.find_by(name: name)
          @current_user.puts <<~MSG
            Entering #{room.name}... enjoy your stay!

            Type `.exit` to exit this chat room.

            Currently in this room:
            #{room.clients.map do |client|
                "- #{client.name}\n"
              end.join}
          MSG
          @current_user.update! room: room

          room.broadcast except: @current_user do
            <<~MSG
              #{@current_user.name} has arrived! Play nice, kids.
            MSG
          end

          room.clients << @current_user
          return
        end

        room = @server.new_room! name: name, clients: [@current_user]

        @current_user.puts <<~MSG
          Created and entered #{room.name}... invite some people or something!

          Type `.exit` to exit this chat room.
        MSG
      end

      desc 'dmlist', 'List your received messages'
      def dmlist
        say 'Your direct messages:'
        msgs = @current_user.received_messages.map do |msg|
          <<~MSG
            From: #{msg.sender.name}

            #{msg.content}
          MSG
        end.join('-' * 10)
        say msgs
      end

      desc 'dm [NAME]', 'Send a direct message to [NAME]'
      def dm name
        if recepient = Client.find_by(name: name)
          say <<~MSG
            Sending a direct message to #{name}...

            The message can span multiple lines.

            Type `.exit` when you're ready to send it.
          MSG
          @current_user.composing_dm = recepient
          return
        end

        say "That user doesn't exist!"
      end

      desc 'exit', 'Closes your connection with the server'
      def exit
        @current_user.exit!
      end
    end
  end
end

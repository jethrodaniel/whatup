# frozen_string_literal: true

require 'thor'
require 'whatup/cli/thor_interactive'

require 'whatup/client/client'
require 'whatup/cli/commands/interactive/dm'

module Whatup
  module CLI
    # Interactive client commands that are available after connecting
    #
    # This class is run on the server
    class Interactive < Thor
      extend ThorInteractive

      Room = Whatup::Server::Room
      Client = Whatup::Server::Client

      no_commands do
        # Checks whether a given input string is a valid command
        def self.command? msg
          cmds, opts = parse_input(msg)
          parsed_args = new(cmds, opts).args
          commands.key?(parsed_args.first) || parsed_args.first == 'help'
        end

        # Parses a client's input into a format suitable for Thor commands
        #
        # param [String] msg - the client's message
        def self.parse_input msg
          # Split user input at the first "option"
          cmds, opts = msg&.split /-|--/, 2

          # Then split each by whitespace
          cmds = cmds&.split(/\s+/)
          opts = opts&.split(/\s+/)

          cmds = [] if cmds.nil?
          opts = [] if opts.nil?

          [cmds, opts]
        end
      end

      desc 'list', 'Show all connected clients'
      def list
        say 'All connected clients:'
        server.clients_except(current_user).each { |c| say "  #{c.status}" }
        say "* #{current_user.status}"
      end

      desc 'room [NAME]', 'Create and enter chatroom [NAME]'
      def room name # rubocop:disable Metrics/AbcSize
        if room = Room.find_by(name: name)
          current_user.puts <<~MSG
            Entering #{room.name}... enjoy your stay!

            Type `.exit` to exit this chat room.

            Currently in this room:
            #{room.clients.map do |client|
                "- #{client.name}\n"
              end.join}
          MSG
          current_user.update! room: room

          server.clients.reject { |c| c.id == current_user.id }.each do |c|
            c.puts <<~MSG
              #{current_user.name} has arrived! Play nice, kids.
            MSG
          end

          room.clients << current_user
          return
        end

        room = server.new_room! name: name, clients: [current_user]

        current_user.puts <<~MSG
          Created and entered #{room.name}... invite some people or something!

          Type `.exit` to exit this chat room.
        MSG
      end

      desc 'exit', 'Closes your connection with the server'
      def exit
        current_user.exit!
      end

      desc 'dm ...', 'Perform direct message commands'
      long_desc <<~DESC
        Perform direct message commands.

        See `dm help [CMD] for more info about specific commands.
      DESC
      subcommand 'dm', Dm
    end
  end
end

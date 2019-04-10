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

          cmds = [] if cmds.nil?
          opts = [] if opts.nil?

          [cmds, opts]
        end
      end

      desc 'list', 'Show all connected clients'
      def list
        say 'All connected clients:'
        local(:server).clients_except(local(:current_user)).each { |c| say "  #{c.status}" }
        say "* #{local(:current_user).status}"
      end

      desc 'room [NAME]', 'Create and enter chatroom [NAME]'
      def room name
        if room = Room.find_by(name: name)
          local(:current_user).puts <<~MSG
            Entering #{room.name}... enjoy your stay!

            Type `.exit` to exit this chat room.

            Currently in this room:
            #{room.clients.map do |client|
                "- #{client.name}\n"
              end.join}
          MSG
          local(:current_user).update! room: room

          room.broadcast except: local(:current_user) do
            <<~MSG
              #{local(:current_user).name} has arrived! Play nice, kids.
            MSG
          end

          room.clients << local(:current_user)
          return
        end

        room = local(:server).new_room! name: name, clients: [local(:current_user)]

        local(:current_user).puts <<~MSG
          Created and entered #{room.name}... invite some people or something!

          Type `.exit` to exit this chat room.
        MSG
      end

      desc 'dmlist', 'List your received messages'
      def dmlist
        say 'Your direct messages:'
        msgs = local(:current_user).received_messages.map do |msg|
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
          local(:current_user).composing_dm = recepient
          return
        end

        say "That user doesn't exist!"
      end

      desc 'exit', 'Closes your connection with the server'
      def exit
        local(:current_user).exit!
      end

      desc 'dm ...', 'Perform direct message commands'
      long_desc <<~DESC
        Perform direct message commands.
      DESC
      subcommand 'dm', Dm
    end
  end
end

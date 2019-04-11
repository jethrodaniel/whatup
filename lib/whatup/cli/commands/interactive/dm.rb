# frozen_string_literal: true

require 'thor'
require 'whatup/cli/thor_interactive'

module Whatup
  module CLI
    # Server commands
    class Dm < Thor
      extend ThorInteractive

      Room = Whatup::Server::Room
      Client = Whatup::Server::Client

      desc 'msg [NAME]', 'Send a message to [NAME]'
      def msg name
        if recepient = Client.find_by(name: name)
          say <<~MSG
            Sending a direct message to #{name}...

            The message can span multiple lines.

            Type `.exit` when you're ready to send it.
          MSG
          current_user.composing_dm = recepient
          return
        end

        say "That user doesn't exist!"
      end

      desc 'list', 'List your received messages'
      def list
        say 'Your direct messages:'
        msgs = current_user.received_messages.map do |msg|
          <<~MSG
            From: #{msg.sender.name}

            #{msg.content}
          MSG
        end.join('-' * 10)
        say msgs
      end
    end
  end
end

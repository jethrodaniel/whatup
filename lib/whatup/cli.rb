# frozen_string_literal: true

require 'thor'

module Whatup
  # Thor command classes for the cli.
  # For usage, see <http://whatisthor.com/>
  module CLI
    # Client commands
    class Client < Thor
      desc 'start', 'Starts a client instance'
      # Starts a client instance
      def start
        say "starting a client ... \n", :green
      end
    end

    # Server commands
    class Server < Thor
      desc 'start', 'Starts a server instance'
      # Starts a server instance
      def start
        say "starting a server ... \n", :green
      end
    end

    # Top-level command class
    class CLI < Thor
      desc 'hello', 'Says hello'
      # Says hello. This is a placeholder for some useful command.
      def hello
        say "Hello!\n", :cyan
      end

      desc 'server ...', 'Perform server commands'
      subcommand 'server', Server

      desc 'client ...', 'Perform client commands'
      subcommand 'client', Client
    end
  end
end

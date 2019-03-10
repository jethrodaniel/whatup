# frozen_string_literal: true

require 'thor'

module Whatup
  # Thor command classes for the cli.
  # For usage, see <http://whatisthor.com/>
  module CLI
    # Client commands
    class Client < Thor
      option :port, type: :numeric, default: 9_001
      long_desc <<~DESC
        Starts a client instance sending requests to the specified port.
      DESC
      desc 'start', 'Starts a client instance'
      # Starts a client instance
      def start
        say "starting a client ... \n", :green
      end
    end

    # Server commands
    class Server < Thor
      option :port, type: :numeric, default: 9_001
      desc 'start', 'Starts a server instance'
      long_desc <<~DESC
        Starts a server instance on the specified port.
      DESC
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
      long_desc <<~DESC
        Perform server commands.

        See `whatup server help COMMAND` for help on `COMMAND`.
      DESC
      subcommand 'server', Server

      desc 'client ...', 'Perform client commands'
      long_desc <<~DESC
        Perform client commands.

        See `whatup client help COMMAND` for help on `COMMAND`.
      DESC
      subcommand 'client', Client
    end
  end
end

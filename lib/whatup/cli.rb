# frozen_string_literal: true

require 'thor'

require 'whatup/server'
require 'whatup/client'

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
      def start
        say "starting a client ... \n", :green
        Whatup::Client.new(port: options[:port]).start
      end
    end

    # Server commands
    class Server < Thor
      option :port, type: :numeric, default: 9_001
      desc 'start', 'Starts a server instance'
      long_desc <<~DESC
        Starts a server instance on the specified port.
      DESC
      def start
        Whatup::Server.new(port: options[:port]).start
      end
    end

    # Top-level command class
    class CLI < Thor
      desc 'hello', 'Says hello'
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

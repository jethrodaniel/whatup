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
      option :ip, type: :string, default: 'localhost'
      option :port, type: :numeric, default: 9_001
      long_desc <<~DESC
        Starts a client instance sending requests to the specified ip and port.
      DESC
      desc 'connect', 'Connects a new client instance to a server'
      def connect
        Whatup::Client.new(ip: options[:ip], port: options[:port]).connect
      end
    end

    # Server commands
    class Server < Thor
      option :port, type: :numeric, default: 9_001
      desc 'start', 'Starts a server instance'
      long_desc <<~DESC
        Starts a server instance running locally on the specified port.
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

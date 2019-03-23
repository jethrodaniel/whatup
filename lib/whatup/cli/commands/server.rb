# frozen_string_literal: true

require 'thor'

require 'whatup/server/server'

module Whatup
  module CLI
    # Server commands
    class Server < Thor
      option :port, type: :numeric, default: 9_001
      desc 'start', 'Starts a server instance'
      long_desc <<~DESC
        Starts a server instance running locally on the specified port.
      DESC
      def start
        Whatup::Server::Server.new(port: options[:port]).start
      end
    end
  end
end

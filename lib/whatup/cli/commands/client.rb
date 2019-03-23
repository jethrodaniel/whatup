# frozen_string_literal: true

require 'thor'

require 'whatup/client/client'

module Whatup
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
        config = {ip: options[:ip], port: options[:port]}
        Whatup::Client::Client.new(config).connect
      end
    end
  end
end

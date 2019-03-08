# frozen_string_literal: true

require 'thor'

module Whatup
  class ClientCLI < Thor
    desc 'start', 'Starts a client instance'
    def start
      say 'starting a client ... ', :green
    end
  end

  class ServerCLI < Thor
    desc 'start', 'Starts a server instance'
    def start
      say 'starting a server ... ', :green
    end
  end

  # Thor command class for the cli.
  # For usage, see <http://whatisthor.com/>
  class CLI < Thor
    desc 'hello', 'Says hello'
    def hello
      say "Hello!", :cyan
    end

    desc 'server ...', 'Perform server commands'
    subcommand 'server', ServerCLI

    desc 'client ...', 'Perform client commands'
    subcommand 'client', ClientCLI
  end
end

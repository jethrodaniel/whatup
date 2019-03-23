# frozen_string_literal: true

require 'thor'

require 'whatup/cli/client'
require 'whatup/cli/server'

module Whatup
  # Thor command classes for the cli.
  # For usage, see <http://whatisthor.com/>
  module CLI
    # Top-level command class
    class CLI < Thor
      desc 'hello', 'Says hello'
      def hello
        say "Hello!\n", :cyan
      end

      # Subcommands are defined below, but are implemented in `commands/`
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

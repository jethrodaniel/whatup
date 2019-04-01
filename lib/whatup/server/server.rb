# frozen_string_literal: true

require 'socket'
require 'fileutils'
require 'securerandom'

require 'whatup/server/client'
require 'whatup/cli/commands/interactive/interactive'

module Whatup
  module Server
    class Server
      include Thor::Shell

      Client = Whatup::Server::Client

      # Used by the interactive client cli
      attr_reader *%i[ip port address clients max_id pid pid_file]

      def initialize port:
        @ip = 'localhost'
        @port = port
        @address = "#{@ip}:#{@port}"

        @clients = []
        @max_id = 1

        @pid = Process.pid
        @pid_file = "#{Dir.home}/.whatup.pid"
      end

      # Starts the server.
      #
      # The server continuously loops, and handle each new client in a separate
      # thread.
      def start
        say "Starting a server with PID:#{@pid} @ #{@address} ... \n", :green

        exit_if_pid_exists!
        connect_to_socket!
        write_pid!

        # Listen for connections, then accept each in a separate thread
        loop do
          Thread.new(@socket.accept) { |client| handle_client client }
        end

        loop do
          Thread.new(@socket.accept) do |client|
            case handle_client client
            when :exit
              client.puts 'bye!'
              Thread.kill Thread.current
            end
          end
        end
      rescue SignalException # In case of ^c
        kill
      end

      private

      # Receives a new client, then continuously gets input from that client
      def handle_client client
        client = create_new_client_if_not_existing! client

        loop do
          msg = client.gets&.chomp

          next if msg.nil?

          msg = 'help' if msg == ''

          puts "#{client.name}> #{msg}" # TODO: use Readline
          parse_input client, msg
          # broadcast_to_all_clients client, msg
        end
      end

      # Receives a username from a client, then creates a new client unless a
      # client with that username already exists.
      #
      # If no username is provided (i.e, blank), it assigns a random, anonymous
      # username in the format `ANON-xxx`, where `xxx` is a random number upto
      # 100, left-padded with zeros.
      def create_new_client_if_not_existing! client
        name     = client.gets.chomp
        rand_num = SecureRandom.random_number(100).to_s.rjust 3, '0'
        name     = name == '' ? "ANON-#{rand_num}" : name

        if @clients.any? { |c| c.name == name }
          client.puts 'That name is taken! Goodbye.'
          return
        end

        @clients << client = Client.new(
          id: new_client_id,
          name: name,
          socket: client
        )

        puts "#{client.name} just showed up!"
        client.puts "Hello, #{client.name}!"
        client
      end

      # Parses a client's input, and manages the client's interactive cli
      #
      # This just splits the user's input by whitespace, then passes that
      # to Thor - at that point, the rest of the parsing and command logic
      # is delegated to the cli classes, and we just catch any exception
      # that is thrown from them in case of a missing command or other input
      # violations.
      #
      # @param [TCPSocket] client - the client that is connecting
      # @param [String] msg - the client's message
      def parse_input client, msg
        # Split user input at the first "option"
        cmds, opts = msg.split /-|--/, 2

        # Then split each by whitespace
        cmds = cmds&.split(/\s+/)
        opts = opts&.split(/\s+/)

        # `Whatup::CLI::Interactive.new(cmds, opts)` expects arrays, and
        # a final options hash
        cmds = [] if cmds.nil?
        opts = [] if opts.nil?

        # Initialize a new cli class using the commands and options, and
        # additionally set any instance variables.
        cli = Whatup::CLI::Interactive.new(cmds, opts).tap do |c|
          c.server = self # We need a mutex for this, actually
        end

        begin
          # TODO: make this accept color outputs
          output = capture_stdout do
            # Invoke the cli using the provided commands and options.
            #
            # This _should_ achieve the same effect as
            # `Whatup::CLI::Interactive.start(args)`, but allows us to set
            # instance variables on the cli class.
            cli.invoke cli.args.first, cli.args[1..cli.args.size - 1]
          end

          # Send the output to the client
          client.puts output
        rescue RuntimeError,
               Thor::InvocationError,
               Thor::UndefinedCommandError => e
          puts e.message
          client.puts 'Invalid input or unknown command'
        end
      end

      # @return A new, unique client identification number
      def new_client_id
        @max_id += 1
      end

      # Capture all stdout within a block into a string.
      # From <https://stackoverflow.com/a/22777806/7132678>
      def capture_stdout
        original_stdout = $stdout
        $stdout = StringIO.new
        yield
        $stdout.string
      ensure
        $stdout = original_stdout
      end

      def broadcast_to_all_clients client, msg
        @clients.reject { |c| c.id == client.id }.each do |c|
          c.puts "\n#{client.name}> #{msg}" unless msg.nil? || msg == ''
        end
      end

      def exit_if_pid_exists!
        return unless running?

        say <<~EXIT, :cyan
          A server appears to already be running!
          Check `#{@pid_file}`.
        EXIT

        kill
      end

      def connect_to_socket!
        @socket = TCPServer.open @port
      rescue Errno::EADDRINUSE
        puts 'Address already in use!'
        kill
      end

      def write_pid!
        File.open(@pid_file, 'w') { |f| f.puts Process.pid }
      end

      def running?
        File.file? @pid_file
      end

      def kill
        say "Killing the server with PID:#{Process.pid} ...", :red
        FileUtils.rm_rf @pid_file
        exit
      end
    end
  end
end

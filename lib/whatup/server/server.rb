# frozen_string_literal: true

require 'socket'
require 'fileutils'

require 'whatup/server/client'
require 'whatup/cli/commands/interactive'

module Whatup
  module Server
    class Server
      include Thor::Shell

      Client = Whatup::Server::Client

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
      rescue SignalException
        kill
      end

      private

      # Receives a username from a client, then creates a new client unless a
      # client with that username already exists.
      def handle_client client
        # Add a new client
        name = client.gets.chomp
        name = name == '' ? 'ANON' : name

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

        loop do
          msg = client.gets&.chomp
          next if msg.nil? || msg == ''

          puts "#{client.name}> #{msg}"
          parse_input client, msg
          # broadcast_to_all_clients client, msg
        end
      end

      # @return A new, unique client identification number
      def new_client_id
        @max_id += 1
      end

      # Parses a client's input, and manages the client's interactive cli
      def parse_input client, msg
        cli = Whatup::CLI::Interactive.new

        cmd, args = *msg.split(/\s+/)

        return if handle_help_commands!(client, cmd, msg)

        # Get the requested command
        cmd = Whatup::CLI::Interactive.commands[cmd]

        if cmd.nil?
          client.puts "unknown command #{cmd}"
          return
        end

        begin
          output = capture_stdout do
            cmd.run cli, *args
          end
          client.puts output
        rescue Thor::InvocationError => e
          client.puts e.message
          return
        end
      end

      # Parses input, and handles any help commands.
      #
      # @return True if the callee should return as well, else nil
      def handle_help_commands! client, cmd, msg
        # If the client enters whitespace, or `help`
        if cmd.nil? || msg == 'help'
          output = capture_stdout do
            Whatup::CLI::Interactive.help Whatup::CLI::Interactive.new
          end
          client.puts output
          return true
        end

        # Handle `help ...` commands separately.
        #
        # {'cmd' => some_command} or nil, if not help
        help_cmd = msg.match(/\Ahelp (?<cmd>\w+)\s*/)&.named_captures

        return unless help_cmd && help_cmd['cmd']

        output = capture_stdout do
          Whatup::CLI::Interactive.command_help(
            Whatup::CLI::Interactive.new,
            help_cmd['cmd']
          )
        end
        client.puts output
        true
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
      end
    end
  end
end

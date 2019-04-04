# frozen_string_literal: true

require 'socket'
require 'fileutils'
require 'securerandom'

require 'active_support/core_ext/object/blank'

require 'whatup/server/client'
require 'whatup/server/room'
require 'whatup/cli/commands/interactive/interactive'

module Whatup
  module Server
    class Server
      include Thor::Shell

      Client = Whatup::Server::Client

      # Used by the interactive client cli
      attr_reader *%i[ip port address clients max_id pid pid_file rooms]

      def initialize port:
        @ip = 'localhost'
        @port = port
        @address = "#{@ip}:#{@port}"

        @clients = []
        @rooms = []
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

      def find_client_by name:
        @clients.select { |c| c.name == name }&.first
      end

      def new_room! clients: [], name:
        room = Room.new name: name, clients: clients
        @rooms << room
        room
      end

      private

      # Receives a new client, then continuously gets input from that client
      #
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def handle_client client
        client = create_new_client_if_not_existing! client

        # Loop forever to maintain the connection
        loop do
          handle_chatting(client) if client.chatting?

          # Wait until we get a valid command. This takes as long as the client
          # takes.
          msg = client.input! unless Whatup::CLI::Interactive.command?(msg)

          puts "#{client.name}> #{msg}"

          # Initialize a new cli class using the initial command and options,
          # and then set any instance variables, since Thor will create a new
          # class instance when it's invoked.
          cmds, opts = Whatup::CLI::Interactive.parse_input msg
          cli = Whatup::CLI::Interactive.new(cmds, opts).tap do |c|
            c.server = self
            c.current_user = client
          end

          begin
            # Send the output to the client
            redirect stdin: client.socket, stdout: client.socket do
              # Invoke the cli using the provided commands and options.

              # This _should_ achieve the same effect as
              # `Whatup::CLI::Interactive.start(args)`, but allows us to set
              # instance variables on the cli class.
              cli.invoke cli.args.first, cli.args[1..cli.args.size - 1]
            end
          rescue RuntimeError,
                 Thor::InvocationError,
                 Thor::UndefinedCommandError => e
            puts e.message
            client.puts 'Invalid input or unknown command'
          rescue ArgumentError => e
            puts e.message
            client.puts e.message
          end
          msg = nil # rubocop:disable Lint/UselessAssignment
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def handle_chatting client
        loop do
          input = client.input!
          room = client.room
          puts "#{client.name}> #{input}"
          if input == '.exit'
            client.leave_room!
            break
          end
          room.broadcast except: client do
            "#{client.name}> #{input}"
          end
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
          client.exit!
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

      # @return A new, unique client identification number
      def new_client_id
        @max_id += 1
      end

      # Reroutes stdin and stdout inside a block
      def redirect stdin: $stdin, stdout: $stdout
        original_stdin  = $stdin
        original_stdout = $stdout
        $stdin  = stdin
        $stdout = stdout
        yield
      ensure
        $stdin  = original_stdin
        $stdout = original_stdout
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

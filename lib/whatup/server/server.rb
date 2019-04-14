# frozen_string_literal: true

require 'socket'
require 'fileutils'
require 'securerandom'

require 'sqlite3'
require 'active_record'
require 'active_support/core_ext/object/blank'

require 'whatup/server/db_init'
require 'whatup/server/redirection'
require 'whatup/server/models/client'
require 'whatup/server/models/message'
require 'whatup/server/models/room'
require 'whatup/cli/commands/interactive/interactive'

module Whatup
  module Server
    class Server # rubocop:disable Metrics/ClassLength
      include Thor::Shell
      include DbInit
      include Redirection

      Client = Whatup::Server::Client

      attr_reader *%i[ip port address clients pid pid_file rooms]

      # @param ip [String] The ip address to run the server on
      # @param port [Integer] The port to run the server on
      #
      # @return [Whatup::Server::Server] The created server
      def initialize ip: 'localhost', port:
        @ip = ip
        @port = port
        @address = "#{@ip}:#{@port}"

        @clients = []
        @rooms = []

        @pid = Process.pid
        @pid_file = "#{Dir.home}/.whatup.pid"

        DbInit.setup_db!
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
      rescue SignalException # In case of ^c
        kill
      end

      # @param client [Whatup::Server::Client] The client to not retrieve
      #
      # @return [Array<Whatup::Server::Client>] All currently connected clients
      #   except for `client`
      def clients_except client
        @clients.reject { |c| c == client }
      end

      # @param clients [Array<Whatup::Server::Client>] Room's inital clients
      # @param name [String] The room's name
      #
      # @return [Whatup::Server::Room] The created room
      def new_room! clients: [], name:
        room = Room.create! name: name, clients: clients
        @rooms << room
        room
      end

      private

      # Receives a new client, then continuously gets input from that client
      #
      # @param client [Whatup::Server::Client] The client
      #
      # rubocop:disable Metrics/MethodLength
      def handle_client client
        client = create_new_client_if_not_existing! client

        # Loop forever to maintain the connection
        loop do
          @clients.reject! &:deleted

          Thread.current.exit if client.deleted

          if client.composing_dm?
            handle_dm client
          elsif client.chatting?
            handle_chatting client
          end

          # Wait until we get a valid command. This takes as long as the client
          # takes.
          msg = client.input! unless Whatup::CLI::Interactive.command?(msg)

          puts "#{client.name}> #{msg}"

          begin
            # Send the output to the client
            redirect stdin: client.socket, stdout: client.socket do
              # Invoke the cli using the provided commands and options.
              run_thor_command! client: client, msg: msg
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
          msg = nil
        end
      end
      # rubocop:enable Metrics/MethodLength

      # Handles inputing direct messages
      #
      # @param client [Whatup::Server::Client] `client` is the sender of
      #   the message, and `client.composing_dm` is the recipient.
      def handle_dm client
        msg = StringIO.new
        loop do
          input = client.input!
          puts "#{client.name}> #{input}"
          msg.puts input
          if input == '.exit'
            client.puts "Finished dm to `#{client.composing_dm.name}`."
            break
          end
        end
        client.composing_dm
              .received_messages << Message.create!(
                sender: client,
                content: msg.string
              )
        client.composing_dm = nil
      end

      # Handles chatting.
      #
      # @param client [Whatup::Server::Client] The client. `client` is assumed
      #   to already belong to a room
      def handle_chatting client
        loop do
          input = client.input!
          audience = @clients.reject { |c| c.id == client.id }
                             .select do |c|
                               client.room.clients.pluck(:id).include? c.id
                             end
          puts "#{client.name}> #{input}"
          if input == '.exit'
            client.puts "Exited `#{client.room.name}`."
            audience.each { |c| c.puts "#{client.name}> LEFT" }
            client.leave_room!
            break
          end
          audience.each { |c| c.puts "#{client.name}> #{input}" }
        end
      end

      # Receives a username from a client, then creates a new client unless a
      # client with that username already exists.
      #
      # If no username is provided (i.e, blank), it assigns a random, anonymous
      # username in the format `ANON-xxx`, where `xxx` is a random number upto
      # 100, left-padded with zeros.
      #
      # @param client [TCPSocket] The client connection
      #
      # @return [Whatup::Server::Client] The created client
      def create_new_client_if_not_existing! client
        name     = client.gets.chomp
        rand_num = SecureRandom.random_number(100).to_s.rjust 3, '0'
        name     = name == '' ? "ANON-#{rand_num}" : name

        if @clients.any? { |c| c.name == name }
          client.puts 'That name is taken! Goodbye.'
          client.puts 'END'
          client.close
          Thread.current.exit
        end

        @clients << client = Client.create!(
          name: name,
          socket: client
        )

        puts "#{client.name} just showed up!"
        client.puts <<~MSG
          Hello, #{client.name}!

          Welcome to whatup.

          To get started, type `help`.
        MSG
        client
      end

      # Initialize a new cli class using the initial command and options,
      # and then set any instance variables, since Thor will create a new
      # class instance when it's invoked.
      #
      # This achieve the same effect as
      # `Whatup::CLI::Interactive.start(args)`, but allows us to set
      # instance variables on the cli class.
      #
      # @param client [Whatup::Server::Client]
      def run_thor_command! client:, msg:
        cmds, opts = Whatup::CLI::Interactive.parse_input msg
        cli = Whatup::CLI::Interactive.new(
          cmds,
          opts,
          locals: {server: self, current_user: client} # config
        )
        cli.invoke cli.args.first, cli.args.drop(1)
      end

      # Kills the server if a PID for this app exists
      def exit_if_pid_exists!
        return unless running?

        say <<~EXIT, :cyan
          A server appears to already be running!
          Check `#{@pid_file}`.
        EXIT

        kill
      end

      # Connect a new socket for this server to start listening on the specified
      # address and port.
      def connect_to_socket!
        @socket = TCPServer.open @ip, @port
      rescue Errno::EADDRINUSE
        puts 'Address already in use!'
        kill
      end

      # Write this process's PID to the PID file
      def write_pid!
        File.open(@pid_file, 'w') { |f| f.puts Process.pid }
      end

      # @return [Bool] Whether or not a PID for this app exists
      def running?
        File.file? @pid_file
      end

      # Kills the server and removes the PID file
      def kill
        say "Killing the server with PID:#{Process.pid} ...", :red
        FileUtils.rm_rf @pid_file
        exit
      end
    end
  end
end

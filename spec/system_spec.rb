require 'whatup/server/server'

require 'support/aruba'
require 'fileutils'

def stop_server_and_remove_pid_file!
  system "kill #{$pid}" if $pid
  FileUtils.rm_f "#{Dir.home}/.whatup.pid"
  sleep 0.5
end

def start_server!
  $pid = spawn 'exe/whatup server start', out: '/dev/null', err: '/dev/null'
  sleep 0.5
end

RSpec.describe 'whatup', type: :aruba do
  before(:all) { ENV['INPUTRC'] = '/dev/null' }

  before(:each) do
    stop_server_and_remove_pid_file!
    start_server!
    run_command 'exe/whatup client connect', exit_timeout: 0.5
  end

  after(:each) { stop_server_and_remove_pid_file! }

  context 'when the server first starts up' do
    let(:pid_file) { "#{Dir.home}/.whatup.pid" }
    it "writes it's pid to a file" do
      sleep 0.5
      expect(File.exist?(pid_file)).to be true
      expect(File.read(pid_file).chomp.to_i).to eq($pid)
    end
  end

  context 'when first connecting to the server' do
    let(:output) do
      <<~OUTPUT
        Connecting to localhost:9001 ...
        ~> zeus
        ~> Please enter your username to establish a connection...
        Hello, zeus!

        Welcome to whatup.

        To get started, type `help`.
        Exiting ...
      OUTPUT
    end

    it 'requires a name' do
      type 'zeus'
      sleep 0.5
      expect(last_command_stopped.output).to eq output
    end
  end # context 'when first connecting to the server'

  context 'after connecting to the server' do
    describe 'help' do
      let(:output) do
        <<~OUTPUT
          Connecting to localhost:9001 ...
          ~> zeus
          ~> help
          ~> Please enter your username to establish a connection...
          Hello, zeus!

          Welcome to whatup.

          To get started, type `help`.
          Commands:
            dm ...          # Perform direct message commands
            exit            # Closes your connection with the server
            help [COMMAND]  # Describe available commands or one specific command
            list            # Show all connected clients
            room [NAME]     # Create and enter chatroom [NAME]

          Exiting ...
        OUTPUT
      end

      it 'shows help' do
        type 'zeus'
        type 'help'
        sleep 0.5
        expect(last_command_stopped.output).to eq output
      end
    end # describe 'help'

    describe 'list' do
      let(:output) do
        <<~OUTPUT
          Connecting to localhost:9001 ...
          ~> zeus
          ~> list
          ~> Please enter your username to establish a connection...
          Hello, zeus!

          Welcome to whatup.

          To get started, type `help`.
          All connected clients:
          * zeus
          Exiting ...
        OUTPUT
      end

      it 'shows all connected clients' do
        type 'zeus'
        sleep 0.5
        type 'list'
        sleep 0.5
        expect(last_command_stopped.output).to eq output
      end
    end # describe 'list'

    describe 'dm' do
      let(:output) do
        <<~OUTPUT
          Connecting to localhost:9001 ...
          ~> zeus
          ~> dm
          ~> Please enter your username to establish a connection...
          Hello, zeus!

          Welcome to whatup.

          To get started, type `help`.
          Commands:
            dm help [COMMAND]  # Describe subcommands or one specific subcommand
            dm list            # List your direct messages
            dm msg [NAME]      # Send a message to [NAME]

          Exiting ...
        OUTPUT
      end

      it 'shows dm help' do
        type 'zeus'
        type 'dm'
        sleep 0.5
        expect(last_command_stopped.output).to eq output
      end
    end # describe 'dm'

    describe 'room' do
      context 'creating a room' do
        let(:output) do
          <<~OUTPUT
            Connecting to localhost:9001 ...
            ~> zeus
            ~> room muchwow
            ~> Please enter your username to establish a connection...
            Hello, zeus!

            Welcome to whatup.

            To get started, type `help`.
            Created and entered muchwow... invite some people or something!

            Type `.exit` to exit this chat room.
            Exiting ...
          OUTPUT
        end

        it 'starts chatting in a new chatroom' do
          type 'zeus'
          sleep 0.5
          type 'room muchwow'
          sleep 0.5
          expect(last_command_stopped.output).to eq output
        end
      end # context 'creating a room'

      context 'exiting a room' do
        let(:output) do
          <<~OUTPUT
            Connecting to localhost:9001 ...
            ~> zeus
            ~> room muchwow
            ~> .exit
            ~> Please enter your username to establish a connection...
            Hello, zeus!

            Welcome to whatup.

            To get started, type `help`.
            Created and entered muchwow... invite some people or something!

            Type `.exit` to exit this chat room.
            Exited `muchwow`.
            Exiting ...
          OUTPUT
        end

        it 'stops chatting upon receiving .exit' do
          type 'zeus'
          sleep 0.5
          type 'room muchwow'
          sleep 0.5
          type '.exit'
          sleep 0.5
          expect(last_command_stopped.output).to include_output_string output
        end
      end # context 'exiting a room'
    end # describe 'room'
  end # context 'after connecting to the server'
end

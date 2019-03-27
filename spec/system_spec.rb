require 'whatup/server/client'
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
  before(:each) do
    stop_server_and_remove_pid_file!
    start_server!
    run_command 'exe/whatup client connect', exit_timeout: 0.1
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
      <<~OUTPUT.gsub /^\s+/, ''
        Connecting to localhost:9001 ...
        Please enter your username to establish a connection...
        > > Hello, zeus!
        Exiting ...
      OUTPUT
    end

    it 'requires a name' do
      type 'zeus'
      sleep 0.5
      expect(last_command_stopped.output).to eq output
    end
  end

  context 'after connecting to the server' do
    let(:output) do
      <<~OUTPUT
        Connecting to localhost:9001 ...
        Please enter your username to establish a connection...
        > > > Hello, zeus!
        Commands:
          chat            # starts a chat with the specified client
          exit            # closes a client's connection with the server
          help [COMMAND]  # Describe available commands or one specific command
          list            # show all connected clients

        Exiting ...
      OUTPUT
    end

    it 'shows help if `help` is called' do
      type 'zeus'
      type 'help'
      sleep 0.5
      expect(last_command_stopped.output).to eq output
    end
  end
end

require 'whatup/server/client'
require 'whatup/server/server'

require 'support/aruba'
require 'fileutils'

def stop_server_and_remove_pid_file!
  system "kill #{$pid}" if $pid
  FileUtils.rm_f "#{Dir.home}/.whatup.pid"
end

RSpec.describe 'whatup', type: :aruba do
  before(:each) do
    run_command 'exe/whatup client connect', exit_timeout: 0.1
  end

  before(:all) do
    stop_server_and_remove_pid_file!
    $pid = spawn 'exe/whatup server start', out: '/dev/null', err: '/dev/null'
  end
  after(:all) { stop_server_and_remove_pid_file! }

  context 'when the server first starts up' do
    let(:pid_file) { "#{Dir.home}/.whatup.pid" }
    it "writes it's pid to a file" do
      sleep 1
      expect(File.exist?(pid_file)).to be true
      expect(File.read(pid_file).chomp.to_i).to eq($pid)
    end
  end

  context 'when first connecting, a name is required' do
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
      sleep 1
      expect(last_command_stopped.output).to eq output
    end
  end
end

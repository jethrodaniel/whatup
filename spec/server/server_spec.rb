# frozen_string_literal: true

require 'whatup/server/server'
require 'socket'

RSpec.describe Whatup::Server::Server do
  subject { Whatup::Server::Server.new port: 9_001 }

  describe '.ip' do
    it 'is the host address that the server is running on' do
      expect(subject.ip).to eq 'localhost'
    end
  end

  describe '.port' do
    it 'is the port that the server is listening on' do
      expect(subject.port).to eq 9_001
    end
  end

  describe '.address' do
    it "is the server's ip and port" do
      expect(subject.address).to eq "#{subject.ip}:#{subject.port}"
    end
  end

  describe '.client' do
    it "is the server's connected client" do
      expect(subject.clients).to eq []
    end
  end

  describe '.pid' do
    it "is the server's process id" do
      expect(subject.pid).to be_a(Integer)
      expect(subject.pid.to_i.positive?).to be true
    end
  end

  describe '.pid_file' do
    it "is a file that contains the server's process id" do
      expect(subject.pid_file).to include '.whatup.pid'
    end
  end
end

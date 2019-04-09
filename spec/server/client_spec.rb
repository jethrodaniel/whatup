# frozen_string_literal: true

require 'whatup/server/server'
require 'whatup/server/models/client'

require 'securerandom'

def random_port
  SecureRandom.rand(100) + 9_001
end

RSpec.describe Whatup::Server::Client do
  let!(:port) { random_port }

  # let! creates the server before the client
  let!(:server) { TCPServer.new 'localhost', port }

  subject(:client) do
    Whatup::Server::Client.new(
      id: 1,
      name: 'jethro',
      socket: TCPSocket.new('localhost', port)
    )
  end

  before(:each) { Whatup::Server::Server.new port: port }

  after(:each) do
    client.socket.close
    server.close
  end

  describe '.id' do
    it 'uniquely identifies the client' do
      expect(client.id).to eq(1)
    end
  end

  describe '.name' do
    it "is the client's provided name" do
      expect(client.name).to eq 'jethro'
    end
  end

  describe '.socket' do
    it "is the client's connection to the server" do
      expect(client.socket).to_not be_nil
    end

    it '.gets' do
      expect(client.socket).to respond_to :gets
    end

    it '.puts' do
      expect(client.socket).to respond_to :puts
    end
  end

  describe '.chatting?' do
    it 'returns whether or not the client is chatting with another client' do
      expect(client.chatting?).to be false
    end
  end
end

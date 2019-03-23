# frozen_string_literal: true

require 'whatup/server/client'

RSpec.describe Whatup::Server::Client do
  subject(:client) { Whatup::Server::Client.new id: 1 }

  describe '.id' do
    it 'identifies the client' do
      expect(client.id).to eq(1)
    end
  end
end

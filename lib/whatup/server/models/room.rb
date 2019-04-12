# frozen_string_literal: true

require 'whatup/server/models/application_record'

module Whatup
  module Server
    class Room < ApplicationRecord
      has_many :clients, foreign_key: 'room_id'

      validates :name, uniqueness: true

      def drop_client! client
        client.update! room_id: nil
      end
    end
  end
end

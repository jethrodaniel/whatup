# frozen_string_literal: true

require 'whatup/server/models/application_record'

module Whatup
  module Server
    class Room < ApplicationRecord
      has_many :clients

      validates :name, uniqueness: true

      def drop_client! client
        client.update! room_id: nil
      end

      def broadcast except: nil
        if except
          clients.where.not id: except.id
        else
          clients
        end.each { |c| c.puts yield }
      end
    end
  end
end

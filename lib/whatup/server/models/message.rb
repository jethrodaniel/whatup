# frozen_string_literal: true

require 'whatup/server/models/application_record'

module Whatup
  module Server
    class Message < ApplicationRecord
      belongs_to :recipient, class_name: 'Client'
      belongs_to :sender, class_name: 'Client', foreign_key: 'sender_id'
    end
  end
end

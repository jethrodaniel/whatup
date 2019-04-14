# frozen_string_literal: true

require 'whatup/server/models/application_record'

module Whatup
  module Server
    class Message < ApplicationRecord
      belongs_to :recipient, class_name: 'Client'
      belongs_to :sender, class_name: 'Client', foreign_key: 'sender_id'

      def to_s
        <<~MSG.gsub '.exit', ''
          From: #{sender.name}
          To: #{recipient.name}
          Date: #{created_at.to_s :db}

          #{content}
        MSG
      end
    end
  end
end

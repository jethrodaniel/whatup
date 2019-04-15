# frozen_string_literal: true

require 'tzinfo'

require 'whatup/server/models/application_record'

module Whatup
  module Server
    class Message < ApplicationRecord
      belongs_to :recipient, class_name: 'Client'
      belongs_to :sender, class_name: 'Client', foreign_key: 'sender_id'

      TZ = TZInfo::Timezone.get 'America/Detroit' # Central time

      def to_s
        <<~MSG.gsub '.exit', ''
          ------------------------------------------------------------
          From: #{sender.name}
          To: #{recipient.name}
          Date: #{TZ.utc_to_local(created_at).to_s :db}

          #{content&.chomp}
          ------------------------------------------------------------
        MSG
      end
    end
  end
end

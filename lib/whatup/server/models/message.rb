# frozen_string_literal: true

require 'whatup/server/models/application_record'

module Whatup
  module Server
    class Message < ApplicationRecord
      belongs_to :client
    end
  end
end

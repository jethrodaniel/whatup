# frozen_string_literal: true

module Whatup
  module Server
    class Client
      attr_reader :id

      def initialize id:
        @id = id
      end
    end
  end
end

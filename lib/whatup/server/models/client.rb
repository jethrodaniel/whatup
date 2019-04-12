# frozen_string_literal: true

require 'whatup/server/models/application_record'

module Whatup
  module Server
    class Client < ApplicationRecord
      has_many :sent_messages, class_name: 'Message',
                               foreign_key: 'sender_id'
      has_many :received_messages, class_name: 'Message',
                                   foreign_key: 'recipient_id'

      belongs_to :room, optional: true

      validates_uniqueness_of :name

      attr_accessor *%i[socket composing_dm deleted]

      def puts msg
        socket&.puts(msg)
      end

      def gets
        socket.gets
      end

      def input!
        loop while (msg = gets).blank?
        msg.chomp
      end

      def chatting?
        !room_id.nil?
      end

      def composing_dm?
        !composing_dm.nil?
      end

      def status
        "#{name}#{chatting? ? " (#{room.name})" : ''}"
      end

      def broadcast msg
        room.broadcast(except: self) { "#{name}> #{msg}" }
      end

      def leave_room!
        room.drop_client! self
      end

      def exit!
        puts 'END'
        socket.close
        @deleted = true
        destroy!
      end
    end
  end
end

# frozen_string_literal: true

require 'whatup/server/models/application_record'

module Whatup
  module Server
    class Client < ApplicationRecord
      has_many :messages
      belongs_to :room, optional: true

      attr_accessor *%i[socket]

      def puts msg
        socket.puts msg
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

      def status
        "#{name}" \
        "#{chatting? ? " (#{@room.name})" : ''}"
      end

      def broadcast msg
        room.broadcast(except: self) { "#{name}> #{msg}" }
      end

      def leave_room!
        broadcast 'LEFT'
        room.drop_client! self
      end

      def exit!
        puts 'END'
        Thread.kill Thread.current
      end
    end
  end
end

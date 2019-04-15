# frozen_string_literal: true

require 'whatup'
require 'whatup/server/redirection'
require 'whatup/server/logger'

module Whatup
  module Server
    module DbInit
      extend Redirection
      extend WhatupLogger

      class << self
        def setup_db!
          log.debug { 'Setting up database ...' }

          db = "#{Dir.home}/.whatup.db"

          if File.exist?(db)
            log.debug { "Using existing database `#{db}" }
          else
            log.debug { "Creating new database `#{db}" }
            SQLite3::Database.new(db)
          end

          ActiveRecord::Base.establish_connection adapter: 'sqlite3',
                                                  database: db

          truncate_sql = <<~SQL
            DROP TABLE IF EXISTS clients_rooms;
            DROP TABLE IF EXISTS clients;
            DROP TABLE IF EXISTS messages;
            DROP TABLE IF EXISTS rooms;
          SQL
          log.debug { "Truncating existing data ...\n#{truncate_sql}" }
          ActiveRecord::Base.connection.execute truncate_sql

          StringIO.new.tap do |io|
            redirect(stdout: io) { create_tables! }
            log.debug { "Creating tables ...\n#{io&.string}" }
          end
        end

        private

        def create_tables!
          ActiveRecord::Schema.define do
            create_table :clients, force: true do |t|
              t.string :name
              t.references :room
              t.timestamps
            end
            create_table :messages, force: true do |t|
              t.string :content
              t.references :sender
              t.references :recipient
              t.timestamps
            end
            create_table :rooms, force: true do |t|
              t.string :name
              t.timestamps
            end
          end
        end
      end
    end
  end
end

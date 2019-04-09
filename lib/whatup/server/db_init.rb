# frozen_string_literal: true

require 'whatup'
require 'whatup/server/redirection'

module Whatup
  module Server
    module DbInit
      extend Redirection

      class << self
        def setup_db!
          db = "#{Whatup.root}/db/whatup.db"
          SQLite3::Database.new(db) unless File.exist?(db)

          ActiveRecord::Base.establish_connection adapter: 'sqlite3',
                                                  database: db

          ActiveRecord::Base.connection.execute <<~SQL
            DROP TABLE IF EXISTS clients_rooms;
            DROP TABLE IF EXISTS clients;
            DROP TABLE IF EXISTS messages;
            DROP TABLE IF EXISTS rooms;
          SQL

          redirect(stdout: StringIO.new) { create_tables! }
        end

        private

        def create_tables!
          ActiveRecord::Schema.define do
            create_table :clients, force: true do |t|
              t.string :name
              t.references :room
            end
            create_table :messages, force: true do |t|
              t.string :content
              t.references :client
            end
            create_table :rooms, force: true do |t|
              t.string :name
            end
          end
        end
      end
    end
  end
end

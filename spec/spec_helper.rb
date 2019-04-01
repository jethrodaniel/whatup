# frozen_string_literal: true

require 'bundler/setup'
require 'whatup'

ENV['INPUTRC'] = '' # Ignore ~/.inputrc

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # expect(something).to be something_else
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end

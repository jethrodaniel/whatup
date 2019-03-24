# frozen_string_literal: true

require 'bundler/setup'
require 'whatup'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# aruba additions
# $LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# ['../support/**/*.rb', '../support/*.rb'].each do |path|
#  ::Dir.glob(::File.expand(path, __FILE__)).each { |f| require_relative f }
# end

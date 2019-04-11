# frozen_string_literal: true

require 'whatup/version'

# Main module for whatup
module Whatup
  # Whatup-specific error class
  class Error < StandardError
  end

  # @return [String] The full path to application root
  def self.root
    Dir.pwd
  end

  # @return [Bool] Whether or not the app is running in a test environment
  def self.testing?
    !!defined?(RSpec)
  end
end

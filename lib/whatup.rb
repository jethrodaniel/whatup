# frozen_string_literal: true

require 'whatup/version'

# Main module for whatup
module Whatup
  # Whatup-specific error class
  class Error < StandardError
  end

  def self.root
    Dir.pwd
  end
end

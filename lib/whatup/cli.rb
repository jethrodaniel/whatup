# frozen_string_literal: true

require 'thor'

# Thor command class for the cli
class CLI < Thor
  desc 'hello', 'Says hello'
  def hello
    Thor::Shell::Basic.new.say "Hello!", :cyan
  end
end

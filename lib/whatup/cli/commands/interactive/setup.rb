# frozen_string_literal: true

module Whatup
  module CLI
    # Implements a `before` hook to set the correct instance variables
    # before any command methods.
    #
    # This is needed, since Thor creates another cli class instance when it is
    # called with `invoke`, and we need to reassign any variables to the new
    # cli instance.
    #
    # TODO: grab commands dynamically
    module ServerSetup
      Whatup::CLI::COMMANDS.each do |cmd|
        define_method cmd do |*args|
          @server = instance_variable_get(:@_initializer)
                    .last[:shell]
                    .base
                    .server
          super *args
        end
      end
    end
  end
end

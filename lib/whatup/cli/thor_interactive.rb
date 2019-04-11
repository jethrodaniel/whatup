# frozen_string_literal: true

require 'thor'

# Allows us to use variables passed into a Thor class's `config[:locals]`
# Allows us to call the variables passed into `config[:locals]` as methods
# in our cli classes
module ThorInstanceVariableHook
  def method_missing method, *args, &block
    var = instance_variable_get(:@_initializer).last[:locals][method]
    return var unless var.nil?

    super
  end

  def respond_to_missing? name, include_private = false
    super
  end
end

module ThorInteractive
  # Don't show app name in command help, i.e, instead of
  # `app command desc`, use `command desc`
  def banner task, _namespace = false, subcommand = false
    task.formatted_usage(self, false, subcommand).to_s
  end

  # Include the instance variable to method hook in our cli classes
  def self.extended base
    base.send :include, ThorInstanceVariableHook
  end
end

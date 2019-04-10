# frozen_string_literal: true

require 'thor'

module ThorInstanceVariableHook
  def local var
    instance_variable_get(:@_initializer).last[:locals][var]
  end
end

module ThorInteractive
  # Don't show app name in command help, i.e, instead of
  # `app command desc`, use `command desc`
  def banner task, _namespace = false, subcommand = false
    task.formatted_usage(self, false, subcommand).to_s
  end

  def self.extended base
    base.send :include, ThorInstanceVariableHook
  end
end

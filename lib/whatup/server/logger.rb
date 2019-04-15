# frozen_string_literal: true

require 'English'
require 'logger'

require 'colorize'

class Logger
  class Formatter
    def call severity, time, _progname, msg
      color = case severity
              when 'DEBUG' then :light_magenta
              when 'INFO' then :light_green
              when 'WARN' then :light_cyan
              when 'ERROR' then :light_red
              when 'FATAL', 'UNKNOWN' then :red
              end

      "[#{severity.colorize color}][#{time}]: #{msg}\n"
    end
  end
end

module WhatupLogger
  # Access a logger, to stdout (for now).
  #
  # Uses logging level ENV['WHATUP_LOG_LEVEL'], which can be WARN, INFO, etc
  def log
    Logger.new(STDOUT).tap do |logger|
      if Logger.constants.map(&:to_s).include? ENV['WHATUP_LOG_LEVEL']
        logger.level = Logger.const_get ENV['WHATUP_LOG_LEVEL']
      else
        logger.level = Logger::INFO
        logger.level = 9001 if Whatup.testing?
      end
    end
  end
end

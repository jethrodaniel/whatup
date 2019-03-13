# frozen_string_literal: true

require 'socket'
require 'fileutils'

module Whatup
  class Server
    include Thor::Shell

    def initialize port:
      @ip = 'localhost'
      @port = port
      @address = "#{@ip}:#{@port}"

      @pid = Process.pid

      @pid_file = "#{Dir.home}/.whatup.pid"
    end

    def start
      say "Starting a server with PID:#{@pid} @ #{@address} ... \n", :green

      exit_if_pid_exists!
      connect_to_socket!
      write_pid!

      # Listen for connections, then accept each in a separate thread
      loop do
        Thread.new @socket.accept do |client|
          handle_client client
        end
      end
    rescue SignalException
      kill
    end

    private

    def handle_client client
      name = client.gets.chomp
      puts "#{name} just showed up!"
      client.puts "Hello, #{name}!"

      client.puts 'Sending you the time ...'

      loop do
        client.puts Time.now
        sleep 1
      end
    end

    def exit_if_pid_exists!
      return unless running?

      say <<~EXIT, :cyan
        A server appears to already be running!
        Check `#{@pid_file}`.
      EXIT

      kill
    end

    def connect_to_socket!
      @socket = TCPServer.open @port
    rescue Errno::EADDRINUSE
      puts 'Address already in use!'
      kill
    end

    def write_pid!
      File.open(@pid_file, 'w') { |f| f.puts Process.pid }
    end

    def running?
      File.file? @pid_file
    end

    def kill
      say "Killing the server with PID:#{Process.pid} ...", :red
      FileUtils.rm_rf @pid_file
    end
  end
end

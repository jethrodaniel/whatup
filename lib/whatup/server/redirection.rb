# frozen_string_literal: true

module Whatup
  module Server
    module Redirection
      # Reroutes stdin and stdout inside a block
      def redirect stdin: $stdin, stdout: $stdout
        original_stdin  = $stdin
        original_stdout = $stdout
        $stdin  = stdin
        $stdout = stdout
        yield
      ensure
        $stdin  = original_stdin
        $stdout = original_stdout
      end
    end
  end
end

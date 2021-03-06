# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'whatup/version'

Gem::Specification.new do |spec|
  spec.name          = 'whatup'
  spec.version       = Whatup::VERSION
  spec.authors       = ['Mark Delk']
  spec.email         = ['jethrodaniel@gmail.com']

  spec.summary       = 'A simple server-based instant messaging application'
  spec.description   = <<~DESC
    whatup is a simple server-based instant messaging application using TCP
    sockets.

    It was created for educational purposes.

    It is in development, and currently is both simplified and insecure.

    Please be careful.
  DESC
  spec.homepage      = 'https://github.com/jethrodaniel/whatup'
  spec.license       = 'MIT'
  spec.required_ruby_version = '~> 2.4'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this
  # section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.  The
  # `git ls-files -z` loads the files in the RubyGem that have been added into
  # git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0")
                     .reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # rubocop:disable Layout/AlignHash
  {
    'pry'        => '~> 0.12.2',
    'pry-byebug' => '~> 3.7',
    'bundler'    => '~> 2.0',
    'rake'       => '~> 12.3.2',
    'rspec'      => '~> 3.8',
    'yard'       => '~> 0.9.18',
    'rubocop'    => '~> 0.65.0',
    'aruba'      => '~> 0.14.9'
  }.each do |gem, version|
    spec.add_development_dependency gem, version
  end

  {
    'activesupport' => '~> 5.2',
    'thor'          => '~> 0.20.3',
    'sqlite3'       => '~> 1.4',
    'activerecord'  => '~> 5.2',
    'tzinfo'        => '~> 1.2',
    'colorize'      => '~> 0.8.1'
  }.each do |gem, version|
    spec.add_dependency gem, version
  end
  # rubocop:enable Layout/AlignHash
end

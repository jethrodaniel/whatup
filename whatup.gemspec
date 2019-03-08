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
  # spec.description   = 'TODO: Write a longer description or delete this line.'
  spec.homepage      = 'https://github.com/jethrodaniel/whatup'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this
  # section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

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

  {
    'pry'     => '~> 0.12.2',
    'bundler' => '~> 2.0',
    'rake'    => '~> 10.0',
    'rspec'   => '~> 3.8'
  }.each do |gem, version|
    spec.add_development_dependency gem, version
  end
end

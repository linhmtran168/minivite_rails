# frozen_string_literal: true

require_relative 'lib/minivite_rails/version'

Gem::Specification.new do |spec|
  spec.name = 'minivite_rails'
  spec.version = MiniviteRails::VERSION
  spec.authors = ['Linh Tran']
  spec.email = ['linh.mtran168@live.com']

  spec.summary = 'Minivite Ruby Gem'
  spec.description = 'Provides a minimalistic way to use Vite.js with Rails.'
  spec.homepage = 'https://github.com/linhmtran168/minivite_rails'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features|example)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'railties', '>= 6.0', '< 8'

  spec.metadata['rubygems_mfa_required'] = 'true'
end

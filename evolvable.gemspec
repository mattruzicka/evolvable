lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'evolvable/version'

Gem::Specification.new do |spec|
  spec.name = 'evolvable'
  spec.version = Evolvable::VERSION
  spec.authors = ['Matt Ruzicka']

  spec.summary = 'Add evolutionary behavior to any Ruby object'
  spec.homepage = 'https://github.com/mattruzicka/evolvable'
  spec.license = 'MIT'
  spec.required_ruby_version = ">= 2.6"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/mattruzicka/evolvable/blob/main/CHANGELOG.md'
  spec.metadata["documentation_uri"] = Evolvable::DOC_URL

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'irb', '>= 1.0'
  spec.add_development_dependency 'readme_yard', '>= 0.5'
end

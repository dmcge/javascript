Gem::Specification.new do |spec|
  spec.name = "javascript"
  spec.version = "0.0.1"
  spec.authors = ["dmcge"]
  spec.email = ["85393840+dmcge@users.noreply.github.com"]

  spec.summary = "Execute your Javascript in Ruby"

  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end

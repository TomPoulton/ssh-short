# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'ssh_short/version'

excude = ['.gitignore', 'Rakefile']

Gem::Specification.new do |gem|
  gem.name          = 'ssh-short'
  gem.version       = SshShort::VERSION
  gem.description   = 'Easy ssh'
  gem.summary       = 'Fewer keystrokes to get things done'
  gem.author        = 'Tom Poulton'
  gem.license       = 'MIT'
  gem.homepage      = 'http://github.com/TomPoulton/ssh-short'

  gem.files         = `git ls-files`.split($/).reject { |file| file =~ /^(#{excude.join('|')})$/ }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end

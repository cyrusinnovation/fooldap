lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'fooldap/version'

Gem::Specification.new do |s|
  s.name        = "fooldap"
  s.version     = Fooldap::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Raibert"]
  s.email       = ["mraibert@cyrusinnovation.com"]
  s.homepage    = "http://github.com/cyrusinnovation/fooldap"
  s.summary     = "A fake LDAP server for use in testing"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "net-ldap"
  s.add_dependency "ruby-ldapserver"

  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md)
  s.require_path = 'lib'
end

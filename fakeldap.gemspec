lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'fakeldap/version'

Gem::Specification.new do |s|
  s.name        = "fakeldap"
  s.version     = FakeLDAP::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Aanand Prasad"]
  s.email       = ["aanand.prasad@gmail.com"]
  s.homepage    = "http://github.com/cyrusinnovation/fakeldap"
  s.summary     = "A fake LDAP server for use in testing"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "net-ldap"
  s.add_development_dependency "ruby-ldapserver"

  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md)
  s.require_path = 'lib'
end

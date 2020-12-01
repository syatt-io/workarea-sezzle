$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'workarea/sezzle/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'workarea-sezzle'
  spec.version     = Workarea::Sezzle::VERSION
  spec.authors     = ['Jeff Yucis']
  spec.email       = ['jeff@syatt.io']
  spec.homepage    = 'https://github.com/syatt-io/workarea-sezzle'
  spec.summary     = 'Sezzle Payments for Workarea'
  spec.description = 'Integrates Sezzle into the Workarea Commerce system.'
  spec.license     = 'Business Software License'

  spec.files = `git ls-files`.split("\n")

  spec.add_dependency 'workarea', '~> 3.x'
end

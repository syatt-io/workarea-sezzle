require 'workarea/testing/teaspoon'

Teaspoon.configure do |config|
  config.root = Workarea::Sezzle::Engine.root
  Workarea::Teaspoon.apply(config)
end

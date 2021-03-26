require 'workarea/sezzle'

module Workarea
  module Sezzle
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::Sezzle

      config.to_prepare do
        Workarea::Storefront::ApplicationController.helper(
          Workarea::Storefront::SezzleHelper
        )
      end
    end
  end
end

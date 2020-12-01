require 'workarea/sezzle'

module Workarea
  module Sezzle
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::Sezzle
    end
  end
end

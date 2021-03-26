module Workarea
  module Storefront
    module SezzleHelper
      def sezzle_language
        I18n.locale == :fr ? 'fr' : 'en'
      end
    end
  end
end

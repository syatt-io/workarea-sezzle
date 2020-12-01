module Workarea
  class Payment
    class Tender
      class Sezzle < Tender
        field :intent, type: String
        field :sezzle_id, type: String
        field :sezzle_response, type: String

        def slug
          :sezzle
        end
      end
    end
  end
end

module Workarea
  class Payment
    module Authorize
      class Sezzle
        include OperationImplementation
        include CreditCardOperation

        # sezzle authorizes the funds on their platform. No call is made to the
        # API. Workarea just records the response for posterity.
        def complete!
          transaction.response = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t(
              'workarea.sezzle.authorize',
              amount: transaction.amount
            ),
            pre_authorized_response_message
          )
        end

        private

        def pre_authorized_response_message
          {
            message: I18n.t('workarea.sezzle.pre_authorized_message',
                            amount: transaction.amount)
          }
        end
      end
    end
  end
end

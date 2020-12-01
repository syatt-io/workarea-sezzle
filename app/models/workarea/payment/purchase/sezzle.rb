module Workarea
  class Payment
    module Purchase
      class Sezzle
        include OperationImplementation
        include CreditCardOperation

        def complete!
          transaction.response = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t(
              'workarea.sezzle.purchase',
              amount: transaction.amount
            ),
            pre_purchased_response_message
          )
        end

        private

        def pre_purchased_response_message
          {
            message: I18n.t('workarea.sezzle.pre_purchased_message',
                            amount: transaction.amount)
          }
        end
      end
    end
  end
end

module Workarea
  class Payment
    class Refund
      class Sezzle
        include OperationImplementation
        include CreditCardOperation

        def complete!
          response = gateway.refund(tender.sezzle_id, transaction_options)
          if response.success?
            transaction.response = ActiveMerchant::Billing::Response.new(
              true,
              I18n.t(
                'workarea.sezzle.refund',
                amount: transaction.amount
              ),
              response.body
            )
          else
            transaction.response = ActiveMerchant::Billing::Response.new(
              false,
              I18n.t('workarea.sezzle.refund'),
              response.body
            )
          end
        end

        def cancel!
          #no-op - nothing to role back on refund.
        end

        private

        def gateway
          Workarea::Sezzle.gateway
        end

        def transaction_options
          {
            amount_in_cents: transaction.amount.cents,
            currency: transaction.amount.currency.iso_code
          }
        end
      end
    end
  end
end

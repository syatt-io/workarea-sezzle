module Workarea
  class Payment
    class Capture
      class Sezzle
        include OperationImplementation
        include CreditCardOperation

        def complete!
          # if the intent of the intial order was CAPTURE then Workarea will just record a message
          # on the transaction and not reach out to the third party. Tenders with an intent of
          # capture will already be captured by sezzle during the users checkout process.
          if tender.intent == 'CAPTURE'
            transaction.response = ActiveMerchant::Billing::Response.new(
              true,
              I18n.t(
                'workarea.sezzle.capture',
                amount: transaction.amount
              ),
              pre_captured_response_message
            )
          else
            gateway_capture
          end
        end

        def cancel!
          return unless transaction.success?

          payment_id = transaction.response.params['id']
          response = gateway.void(payment_id)

          transaction.cancellation = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t('workarea.sezzle.void'),
            response.body
          )
        end

        private

        def pre_captured_response_message
          {
            message: I18n.t('workarea.sezzle.pre_captured_message',
                            amount: transaction.amount)
          }
        end

        def gateway
          Workarea::Sezzle.gateway
        end

        def transaction_options
          {
            capture_amount: {
              amount_in_cents: tender.amount.cents,
              currency: transaction.amount.currency.iso_code
            },
            partial_capture: transaction.amount < tender.amount
          }
        end

        def gateway_capture
          response = gateway.capture(tender.sezzle_id, transaction_options)

          if response.success?
            transaction.response = ActiveMerchant::Billing::Response.new(
              true,
              I18n.t(
                'workarea.sezzle.capture',
                amount: transaction.amount
              ),
              response.body
            )
          else
            transaction.response = ActiveMerchant::Billing::Response.new(
              false,
              I18n.t('workarea.sezzle.capture_failure'),
              response.body
            )
          end
        end
      end
    end
  end
end

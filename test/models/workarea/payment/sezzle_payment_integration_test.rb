require 'test_helper'

module Workarea
  class SezzlePaymentIntegrationTest < Workarea::TestCase
    def test_auth_capture
      transaction = tender.build_transaction(action: 'authorize')
      Payment::Authorize::Sezzle.new(tender, transaction).complete!

      assert(transaction.success?)
      transaction.save!

      capture = Payment::Capture.new(payment: payment)
      capture.allocate_amounts!(total: 5.to_m)
      assert(capture.valid?)
      capture.complete!

      capture_transaction = payment.transactions.detect(&:captures)
      assert(capture_transaction.valid?)
    end

    def test_auth_capture_refund
      tender.amount = 5.to_m
      transaction = tender.build_transaction(action: 'authorize')
      operation = Payment::Authorize::Sezzle.new(tender, transaction)
      operation.complete!
      assert(transaction.success?, 'expected transaction to be successful')
      transaction.save!

      capture = Payment::Capture.new(payment: payment)
      capture.allocate_amounts!(total: 5.to_m)
      assert(capture.valid?)
      capture.complete!

      capture_transaction = payment.transactions.detect(&:captures)
      assert(capture_transaction.valid?)

      refund = Payment::Refund.new(payment: payment)
      refund.allocate_amounts!(total: 5.to_m)

      assert(refund.valid?)
      refund.complete!

      refund_transaction = payment.sezzle.transactions.refunds.first
      assert(refund_transaction.valid?)
    end

    private

    def payment
      @payment ||=
        begin
          profile = create_payment_profile
          create_payment(
            profile_id: profile.id,
            address: {
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '22 s. 3rd st.',
              city: 'Philadelphia',
              region: 'PA',
              postal_code: '19106',
              country: Country['US']
            }
          )
        end
    end

    def tender
      @tender ||=
        begin
          payment.set_address(first_name: 'Ben', last_name: 'Crouse')

          payment.build_sezzle(
            sezzle_id: '12345',
            amount: 5.to_m
          )

          payment.sezzle
        end
    end
  end
end

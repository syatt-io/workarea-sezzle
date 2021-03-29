require 'test_helper'

module Workarea
  module Storefront
    class SezzleIntengrationTest < Workarea::IntegrationTest
      setup do
        create_tax_category(
          name: 'Sales Tax',
          code: '001',
          rates: [{ percentage: 0.07, country: 'US', region: 'PA' }]
        )

        product = create_product(
          variants: [{ sku: 'SKU1', regular: 6.to_m, tax_code: '001' }]
        )

        create_shipping_service(
          carrier: 'UPS',
          name: 'Ground',
          service_code: '03',
          tax_code: '001',
          rates: [{ price: 7.to_m }]
        )

        post storefront.cart_items_path,
             params: {
               product_id: product.id,
               sku: product.skus.first,
               quantity: 2
             }

        patch storefront.checkout_addresses_path,
              params: {
                email: 'bcrouse@workarea.com',
                billing_address: {
                  first_name: 'Ben',
                  last_name: 'Crouse',
                  street: '12 N. 3rd St.',
                  city: 'Philadelphia',
                  region: 'PA',
                  postal_code: '19106',
                  country: 'US',
                  phone_number: '2159251800'
                },
                shipping_address: {
                  first_name: 'Ben',
                  last_name: 'Crouse',
                  street: '22 S. 3rd St.',
                  city: 'Philadelphia',
                  region: 'PA',
                  postal_code: '19106',
                  country: 'US',
                  phone_number: '2159251800'
                }
              }

        patch storefront.checkout_shipping_path
      end

      def test_start_clears_credit_card_and_sets_sezzle_payment
        Workarea.config.sezzle_payment_action = 'AUTH'

        payment = Payment.find(order.id)
        payment.set_credit_card({
                                  month: '01',
                                  year: Time.now.year + 1,
                                  number: 1,
                                  cvv: '123'
                                })

        payment.reload

        get storefront.start_sezzle_path

        payment.reload
        order.reload

        refute(payment.credit_card.present?)
        assert(payment.sezzle.present?)
        assert(payment.sezzle.sezzle_id.present?)
        assert_equal('AUTH', payment.sezzle.intent)
      end

      def test_cancel_removes_sezzle
        payment = Payment.find(order.id)

        payment.set_sezzle(
          sezzle_id: '1234',
          sezzle_response: '{}'
        )

        assert(payment.sezzle?)

        get storefront.cancel_sezzle_path(order_id: order.id)
        payment.reload

        refute(payment.sezzle?)
      end

      def test_placing_order_from_sezzle
        payment = Payment.find(order.id)

        payment.set_sezzle(
          sezzle_id: '1234',
          sezzle_response: '{}',
          intent: 'AUTH'
        )

        get storefront.complete_sezzle_path(order_id: order.id)

        payment.reload
        order.reload

        assert(order.placed?)

        transactions = payment.tenders.first.transactions
        assert_equal(1, transactions.size)
        assert(transactions.first.success?)
        assert_equal('authorize', transactions.first.action)
      end

      def test_placing_order_with_dual_payment
        payment = Payment.find(order.id)
        payment.profile = create_payment_profile(email: order.email)

        payment.profile.update_attributes!(store_credit: 1.00)
        payment.set_store_credit
        payment.tenders.first.amount = 1.to_m
        payment.save!

        payment.set_sezzle(
          sezzle_id: '1234',
          sezzle_response: '{}',
          intent: 'AUTH'
        )

        get storefront.complete_sezzle_path(order_id: order.id)

        payment.reload
        order.reload

        assert(order.placed?)
        transactions = payment.transactions
        assert_equal(2, transactions.size)

        sezzle_tender = payment.tenders.detect { |t| t.slug == :sezzle }
        assert(sezzle_tender.transactions.first.success?)
        assert_equal('authorize', sezzle_tender.transactions.first.action)

        store_credit_tender = payment.tenders.detect { |t| t.slug == :store_credit }
        assert(store_credit_tender.transactions.first.success?)

        # Workarea v3.0.53, v3.1.40, v3.2.29, v3.3.21 and greater sets store credit to purchase by
        # default.
        assert_equal('purchase', store_credit_tender.transactions.first.action)
      end

      def test_failed_sezzle_authorize
        payment = Payment.find(order.id)

        payment.set_sezzle(
          sezzle_id: 'failure',
          sezzle_response: '{}'
        )

        get storefront.complete_sezzle_path(order_id: order.id)
        payment.reload
        order.reload

        refute(order.placed?)
      end

      private

      def order
        @order ||= Order.first
       end

      def product
        @product ||= create_product(
          variants: [{ sku: 'SKU1', regular: 6.to_m, tax_code: '001' }]
        )
      end

      def get_order_response(amount)
        b = {
          "amount": {
            "amount": "#{amount}",
            "currency": 'USD'
          }
        }
        Workarea::Sezzle::Response.new(response(b))
      end

      def response(body, status = 200)
        response = Faraday.new do |builder|
          builder.adapter :test do |stub|
            stub.get('/v2/bogus') { |env| [ status, {}, body.to_json ] }
          end
        end
        response.get('/v2/bogus')
      end
    end
  end
end

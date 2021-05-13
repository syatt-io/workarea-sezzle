require 'test_helper'

module Workarea
  module Sezzle
    class OrderBuilderTest < Workarea::TestCase
      setup :set_i18n
      teardown :reset_i18n

      def set_i18n
        @_default_locale = ::I18n.config.default_locale
        @_locale = ::I18n.locale

        ::I18n.config.default_locale = :en
        ::I18n.locale = :en
      end

      def reset_i18n
        ::I18n.config.default_locale = @_default_locale
        ::I18n.locale = @_locale
      end

      def test_build
        create_order_total_discount
        order = create_order

        # apply store credit
        payment = Workarea::Payment.find(order.id)
        payment.profile.update_attributes!(store_credit: 1.00)
        payment.set_store_credit
        payment.tenders.first.amount = 1.to_m
        payment.save

        order.reload
        payment.reload

        ::I18n.locale = :fr
        order_hash = Workarea::Sezzle::OrderBuilder.new(order).build

        assert_includes(order_hash[:cancel_url][:href], 'locale=fr')
        assert_includes(order_hash[:complete_url][:href], 'locale=fr')

        assert_nothing_raised { order_hash.to_json }

        ::I18n.locale = :en
        order_hash = Workarea::Sezzle::OrderBuilder.new(order).build

        assert_nothing_raised { order_hash.to_json }

        refute_includes(order_hash[:cancel_url][:href], 'locale=')
        refute_includes(order_hash[:complete_url][:href], 'locale=')

        customer = order_hash[:customer]
        assert_equal(order.email, customer[:email])
        assert_equal('Bob', customer[:first_name])
        assert_equal('Clams', customer[:last_name])
        assert_equal(expected_billing_address, customer[:billing_address])
        assert_equal(expected_shipping_address, customer[:shipping_address])

        sezzle_order = order_hash[:order]
        assert_equal('1234', sezzle_order[:reference_id])
        refute(sezzle_order[:requires_shipping_info])

        item = sezzle_order[:items].first
        assert_equal('Test Product', item[:name])
        assert_equal('SKU', item[:sku])
        assert_equal(2, item[:quantity])

        assert_equal(900, sezzle_order[:order_amount][:amount_in_cents])
        assert_equal(100, sezzle_order[:shipping_amount][:amount_in_cents])
        assert_equal(0, sezzle_order[:tax_amount][:amount_in_cents])

        discounts = sezzle_order[:discounts]
        assert_equal('Order Total Discount', discounts.first[:name])
        assert_equal(100, discounts.first[:amount][:amount_in_cents])
      end

      private

      def create_order(overrides = {})
        attributes = {
          id: '1234',
          email: 'bcrouse-new@workarea.com',
          placed_at: Time.current
        }.merge(overrides)

        shipping_service = create_shipping_service
        product = create_product(variants: [{ sku: 'SKU', regular: 5.to_m }])

        order = Workarea::Order.new(attributes)
        order.add_item(product_id: product.id, sku: 'SKU', quantity: 2)

        checkout = Checkout.new(order)
        checkout.update(
          shipping_address: {
            first_name: 'Jeff',
            last_name: 'Yucis',
            street: '22 S. 3rd St.',
            street_2: 'Second Floor',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US'
          },
          billing_address: {
            first_name: 'Bob',
            last_name: 'Clams',
            street: '12 N. 3rd St.',
            street_2: 'Second Floor',
            city: 'Wilmington',
            region: 'DE',
            postal_code: '18083',
            country: 'US'
          },
          shipping_service: shipping_service.name,
        )

        order
      end

      def expected_billing_address
        {
          name: 'Bob Clams',
          street: '12 N. 3rd St.',
          street2: 'Second Floor',
          city: 'Wilmington',
          state: 'DE',
          postal_code: '18083',
          country_code: 'US',
          phone_number: nil
        }
      end

      def expected_shipping_address
        {
          name: 'Jeff Yucis',
          street: '22 S. 3rd St.',
          street2: 'Second Floor',
          city: 'Philadelphia',
          state: 'PA',
          postal_code: '19106',
          country_code: 'US',
          phone_number: nil
        }
      end
    end
  end
end

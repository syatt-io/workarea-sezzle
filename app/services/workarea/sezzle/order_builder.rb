module Workarea
  module Sezzle
    class OrderBuilder
      module Routing
        include Workarea::I18n::DefaultUrlOptions
        include Storefront::Engine.routes.url_helpers
        extend self
      end
      attr_reader :order

      # @param  ::Workarea::Order
      def initialize(order)
        @order = Workarea::Storefront::OrderViewModel.new(order)
      end

      def build
        {
          cancel_url: {
            href: cancel_url,
            method: 'GET'
          },
          complete_url: {
            href: complete_url,
            method: 'GET'
          },
          customer: {
            tokenization: true,
            email: order.email,
            first_name: payment.address.first_name,
            last_name: payment.address.last_name,
            phone: phone_number,
            dob: nil, # workarea does not collect oob,
            billing_address: address(payment.address),
            shipping_address: address(shipping&.address)
          },
          order: {
            intent: Workarea.config.sezzle_payment_action,
            reference_id: order.id,
            description: "Sezzle Order #{order.id}",
            requires_shipping_info: false,
            items: items,
            discounts: discounts,
            shipping_amount: {
              amount_in_cents: order.shipping_total.cents,
              currency: currency_code
            },
            tax_amount: {
              amount_in_cents: order.tax_total.cents,
              currency: currency_code
            },
            order_amount: {
              amount_in_cents: order.order_balance.cents,
              currency: currency_code
            }
          }
        }
      end

      private

      def currency_code
        @currency_code = order.total_price.currency.iso_code
      end

      def shipping
        @shipping = Workarea::Shipping.find_by_order(order.id)
      end

      def payment
        @payment = Workarea::Payment.find(order.id)
      end

      def address(address_obj)
        return {} unless address_obj.present?

        {
          name: "#{address_obj.first_name} #{address_obj.last_name}",
          street: address_obj.street,
          street2: address_obj.street_2,
          city: address_obj.city,
          state: address_obj.region,
          postal_code: address_obj.postal_code,
          country_code: address_obj.country.alpha2,
          phone_number: address_obj.phone_number
        }
      end

      def items
        order.items.map do |oi|
          product = Workarea::Catalog::Product.find_by_sku(oi.sku)
          {
            name: product.name,
            sku: oi.sku,
            quantity: oi.quantity,
            price: {
              amount_in_cents: oi.total_price.cents,
              currency: currency_code
            }
          }
        end
      end

      def discounts
        discounts = order.price_adjustments.select { |p| p.discount? }
        discounts.map do |d|
          {
            name: d.description,
            amount: {
              amount_in_cents: d.amount.abs.cents,
              currency: currency_code
            }
          }
        end
      end

      def complete_url
        Routing.complete_sezzle_url(
          host: Workarea.config.host,
          order_id: order.id
        )
      end

      def cancel_url
        Routing.cancel_sezzle_url(
          host: Workarea.config.host,
          order_id: order.id
        )
      end

      def phone_number
        payment.address.phone_number || shipping.address.phone_number
      end
    end
  end
end

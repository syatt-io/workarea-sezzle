module Workarea
  class Storefront::SezzleController < Storefront::ApplicationController
    include Storefront::CurrentCheckout

    before_action :validate_checkout

    def start
      self.current_order = current_checkout.order

      Pricing.perform(current_order, current_shipping)

      check_inventory || (return)

      # get a sezzle session for the current order
      order_payload = Sezzle::OrderBuilder.new(current_order).build
      response = gateway.create_session(order_payload)

      if !response.success?
        flash[:error] = t('workarea.storefront.sezzle.payment_error')
        redirect_to(checkout_payment_path) && (return)
      end

      payment = Workarea::Payment.find(current_order.id)

      payment.clear_credit_card

      tender_attrs = {
        sezzle_id: response.body['order']['uuid'],
        sezzle_response: response.body.to_json,
        intent: Workarea.config.sezzle_payment_action
      }

      payment.set_sezzle(tender_attrs)

      redirect_url = response.body['order']['checkout_url']
      redirect_to redirect_url
    end

    def complete
      self.current_order = Order.find(params[:order_id]) rescue nil
      payment = current_checkout.payment

      current_order.user_id = current_user.try(:id)
      check_inventory || (return)

      shipping = current_shipping

      # verify that the authorization was successfull
      tender = payment.sezzle
      verifcation_response = gateway.get_order(tender.sezzle_id)
      verfied =  verifcation_response.body["authorization"]["approved"] rescue false

      Pricing.perform(current_order, shipping)
      payment.adjust_tender_amounts(current_order.total_price)

      # place the order.
      if verfied && current_checkout.place_order
        completed_place_order
      else
        incomplete_place_order
      end
    end

    def cancel
      self.current_order = Order.find(params[:order_id])

      current_order.user_id = current_user.try(:id)

      payment = current_checkout.payment
      payment.clear_sezzle

      flash[:success] = t('workarea.storefront.sezzle.cancel_message')

      redirect_to checkout_payment_path
    end

    private

    def gateway
      Sezzle.gateway
    end

    def completed_place_order
      Storefront::OrderMailer.confirmation(current_order.id).deliver_later
      self.completed_order = current_order
      clear_current_order

      flash[:success] = t('workarea.storefront.flash_messages.order_placed')
      redirect_to finished_checkout_destination
    end

    def incomplete_place_order
      if current_checkout.shipping.try(:errors).present?
        flash[:error] = current_checkout.shipping.errors.to_a.to_sentence
        redirect_to checkout_shipping_path
      else
        flash[:error] = t('workarea.storefront.sezzle.payment_error')

        payment = current_checkout.payment
        payment.clear_sezzle

        redirect_to checkout_payment_path
      end
    end

    def finished_checkout_destination
      if current_admin.present? && current_admin.orders_access?
        admin.order_path(completed_order)
      else
        checkout_confirmation_path
      end
    end
  end
end

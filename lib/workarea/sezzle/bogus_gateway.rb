module Workarea
  module Sezzle
    class BogusGateway
      def initialize(*)
      end

      def create_session(order)
        b = {
          "uuid": 'fadbc642-05a4-4e38-9e74-80e325623af9',
          "links": [
            {
              "href": 'https://gateway.sezzle.com/v2/session/fadbc642-05a4-4e38-9e74-80e325623af9',
              "method": 'GET',
              "rel": 'self'
            }
          ],
          "order": {
            "uuid": '12a34bc5-6de7-890f-g123-4hi1238jk902',
            "intent": 'CAPTURE',
            "checkout_url": 'https://checkout.sezzle.com/?id=12a34bc5-6de7-890f-g123-4hi1238jk902',
            "links": [
              {
                "href": 'https://gateway.sezzle.com/v2/order/12a34bc5-6de7-890f-g123-4hi1238jk902',
                "method": 'GET',
                "rel": 'self'
              },
              {
                "href": 'https://gateway.sezzle.com/v2/order/12a34bc5-6de7-890f-g123-4hi1238jk902',
                "method": 'PATCH',
                "rel": 'self'
              },
              {
                "href": 'https://gateway.sezzle.com/v2/order/12a34bc5-6de7-890f-g123-4hi1238jk902/release',
                "method": 'POST',
                "rel": 'release'
              },
              {
                "href": 'https://gateway.sezzle.com/v2/order/12a34bc5-6de7-890f-g123-4hi1238jk902/capture',
                "method": 'POST',
                "rel": 'capture'
              },
              {
                "href": 'https://gateway.sezzle.com/v2/order/12a34bc5-6de7-890f-g123-4hi1238jk902/refund',
                "method": 'POST',
                "rel": 'refund'
              }
            ]
          },
          "tokenize": {
            "token": '7ec98824-67cc-469c-86ab-f9e047f9cf1a',
            "expiration": '2020-04-27T14:46:59Z',
            "approval_url": 'https://dashboard.sezzle.com/customer/checkout-approval?merchant-request-id=3f3244fd-78ce-4994-af0c-b8c760d47794',
            "links": [
              {
                "href": 'https://gateway.sezzle.com/v2/token/7ec98824-67cc-469c-86ab-f9e047f9cf1a/session ',
                "method": 'GET',
                "rel": 'token'
              }
            ]
          }
        }

        Response.new(response(b))
      end

      def capture(id, attrs)
        if id == 'error'
          Response.new(response(error_response_body, 400))
        else
          Response.new(response(payment_response_body, 200))
        end
      end

      def authorize(id, attrs)
        if id == 'error'
          Response.new(response(error_response_body, 400))
        elsif id == 'timeout_token'
          Response.new(response(nil, 502))
        else
          Response.new(response(payment_response_body, 200))
        end
      end

      def purchase(id, attrs)
        if id == 'error'
          Response.new(response(error_response_body, 402))
        else
          Response.new(response(payment_response_body, 200))
        end
      end

      def refund(id, attrs)
        Response.new(response(payment_response_body, 200))
      end

      def void(payment_id)
        Response.new(response(payment_response_body))
      end

      def get_order(id, attrs = {})
        return Response.new(response(get_order_response_auth_failure)) if id == 'failure'
        Response.new(response(get_order_response))
      end

      private

      def response(body, status = 200)
        response = Faraday.new do |builder|
          builder.adapter :test do |stub|
            stub.get('/v1/bogus') { |env| [ status, {}, body.to_json ] }
          end
        end
        response.get('/v1/bogus')
      end

      def error_response_body
        [
          {
            "code": 'invalid',
            "message": 'Order must have a valid intent',
            "location": 'order.intent'
          }
        ]
      end

      def payment_response_body(status: 'APPROVED')
        {
          "uuid": '6c9db5d4-d09a-4224-860a-b5438ac32ca8'
        }
      end

      def get_order_response
        {
          "authorization": {
              "approved": true,
              "authorization_amount": {
                  "amount_in_cents": 10000,
                  "currency": "USD"
                },
            "metadata": {
                "location_id": "123",
                "store_manager": "Jane Doe",
                "store_name": "Downtown Minneapolis"
            },
            "order_amount": {
                "amount_in_cents": 10000,
                "currency": "USD"
            },
            "reference_id": "ord_12345",
            "uuid": "12a34bc5-6de7-890f-g123-4hi1238jk902"
          }
        }
      end

      def get_order_response_auth_failure
        {
          "authorization": {
              "approved": false,
              "authorization_amount": {
                  "amount_in_cents": 10000,
                  "currency": "USD"
              },
            "metadata": {
                "location_id": "123",
                "store_manager": "Jane Doe",
                "store_name": "Downtown Minneapolis"
            },
            "order_amount": {
                "amount_in_cents": 10000,
                "currency": "USD"
            },
            "reference_id": "ord_12345",
            "uuid": "12a34bc5-6de7-890f-g123-4hi1238jk902"
          }
        }
      end
    end
  end
end

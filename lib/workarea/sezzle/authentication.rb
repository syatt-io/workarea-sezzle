module Workarea
  module Sezzle
    module Authentication
      class AuthenticationError < StandardError; end
      def token
        response = get_token
        body = JSON.parse(response.body)

        raise AuthenticationError, response.body.to_s unless response.success?
        body['token']
      end

      private

      def get_token
        Rails.cache.fetch(token_cache_key, expires_in: 5.minutes) do

          body = {
            public_key: api_public_key,
            private_key: api_private_key
          }

          conn = Faraday.new(url: rest_endpoint)
          conn.post do |req|
            req.url 'v2/authentication'
            req.headers['Content-Type'] = 'application/json'
            req.body = body.to_json
          end
        end
      end

      def api_public_key
        options[:api_public_key]
      end

      def api_private_key
        options[:api_private_key]
      end

      def test
        options[:test]
      end

      def token_cache_key
        Digest::MD5.hexdigest "#{api_public_key}#{api_private_key}#{test}"
      end
    end
  end
end

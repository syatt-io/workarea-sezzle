module Workarea
  module Sezzle
    class Gateway
      include Sezzle::Authentication
      attr_reader :options

      def initialize(options = {})
        requires!(options, :api_public_key, :api_private_key)
        @options = options
      end

      def create_session(attrs = {})
        response = connection.post do |req|
          req.url 'v2/session'
          req.body = attrs.to_json
        end
        Sezzle::Response.new(response)
      end

      def authorize(id, attrs)
        response = connection.post do |req|
          req.url "v2/order/#{id}/capture"
          req.body = attrs.to_json
        end
        Sezzle::Response.new(response)
      end
      alias :purchase :authorize
      alias :capture :authorize

      def refund(id, attrs)
        response = connection.post do |req|
          req.url "v2/order/#{id}/refund"
          req.body = attrs.to_json
        end
        Sezzle::Response.new(response)
      end

      def get_order(id, attrs = {})
        response = connection.get do |req|
          req.url "v2/order/#{id}"
        end
        Sezzle::Response.new(response)
      end

      private

      def connection
        request_timeouts = {
          timeout: Workarea.config.sezzle[:api_timeout],
          open_timeout: Workarea.config.sezzle[:open_timeout]
        }

        Faraday.new(url: rest_endpoint, headers: api_headers, request: timeout_options)
      end

      def rest_endpoint
        if test?
          'https://sandbox.gateway.sezzle.com'
        else
          'https://gateway.sezzle.com'
        end
      end

      def test?
        (options.has_key?(:test) ? options[:test] : false)
      end

      def api_headers
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Authorization' => "Bearer #{token}"
        }
      end

      def timeout_options
        {
          timeout: Workarea.config.sezzle[:api_timeout],
          open_timeout: Workarea.config.sezzle[:open_timeout]
        }
      end

      def requires!(hash, *params)
        params.each do |param|
          if param.is_a?(Array)
            raise ArgumentError.new("Missing required parameter: #{param.first}") unless hash.has_key?(param.first)

            valid_options = param[1..-1]
            raise ArgumentError.new("Parameter: #{param.first} must be one of #{valid_options.to_sentence(words_connector: 'or')}") unless valid_options.include?(hash[param.first])
          else
            raise ArgumentError.new("Missing required parameter: #{param}") unless hash.has_key?(param)
          end
        end
     end
    end
  end
end

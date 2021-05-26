module Workarea
  module Sezzle
    class Response
      def initialize(response)
        @response = response
      end

      def success?
        @response.present? && [200, 201, 204].include?(@response.status)
      end

      def body
        return {} unless @response.body.present? && @response.body != 'null'

        response_body = JSON.parse(@response.body)

        return response_body.first if response_body.kind_of?(Array)

        response_body
      end

      def status
        @response.status
      end
    end
  end
end

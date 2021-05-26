require 'test_helper'

module Workarea
  module Sezzle
    class ResponseTest < TestCase
      def test_success?
        assert(Response.new(OpenStruct.new(status: 200)).success?)
        assert(Response.new(OpenStruct.new(status: 201)).success?)
        assert(Response.new(OpenStruct.new(status: 204)).success?)
        refute(Response.new(OpenStruct.new(status: 500)).success?)
      end
    end
  end
end

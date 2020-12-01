require 'workarea'
require 'workarea/storefront'
require 'workarea/admin'

require 'workarea/sezzle/engine'
require 'workarea/sezzle/version'

require 'workarea/sezzle/bogus_gateway'
require 'workarea/sezzle/authentication'
require 'workarea/sezzle/gateway'
require 'workarea/sezzle/response'

module Workarea
  module Sezzle
    def self.config
      Workarea.config.sezzle
    end

    # used for <= 3.5, these creds come from secrets isntead of encrypted in the
    # 3.5 configurations system.
    def self.credentials
      (Rails.application.secrets.sezzle || {}).deep_symbolize_keys
    end

    def self.api_public_key
      Workarea.config.sezzle_public_key || credentials[:api_public_key]
    end

    def self.api_private_key
      Workarea.config.sezzle_private_key || credentials[:api_private_key]
    end

    def self.api_configured?
      api_public_key.present? && api_private_key.present?
    end

    def self.test?
      Workarea.config.sezzle_test_mode || credentials[:test]
    end

    def self.gateway
      if Rails.env.test?
        Sezzle::BogusGateway.new
      else
        Sezzle::Gateway.new(
          api_public_key: api_public_key,
          api_private_key: api_private_key,
          test: test?
        )
      end
    end
  end
end

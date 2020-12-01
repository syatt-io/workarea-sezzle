if Workarea::Configuration.respond_to?(:define_fields)
  Workarea::Configuration.define_fields do
    fieldset 'Sezzle', namespaced: true do
      field 'Public Key',
            type: :string,
            description: 'Public Key from merchant dashboard.',
            allow_blank: false,
            encrypted: false

      field 'Private Key',
            type: :string,
            description: 'Private Key from merchant dashboard.',
            allow_blank: false,
            encrypted: true

      field 'Merchant ID',
            type: :string,
            default: 'TODO',
            description: 'Merchant ID from merchant dashboard.',
            allow_blank: false,
            encrypted: false

      field 'Payment Action',
            type: :string,
            description: 'Determines if the order payment is authorized or immediately catpured.',
            allow_blank: false,
            encrypted: false,
            default: 'AUTH'

      field 'Test Mode',
            type: :boolean,
            description: 'Uses the sandbox API endpoints if set to true. Contact your Sezzle representative for sandbox credentials.',
            default: !Rails.env.production?
    end
  end
else

  Workarea.config.sezzle_test_mode = !Rails.env.production?
  Workarea.config.sezzle_payment_action = 'AUTH'
  Workarea.config.sezzle_merchant_id = nil # Host apps are responsible for adding this configuration
end

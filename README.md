Workarea Sezzle
================================================================================

A Sezzle payments plugin for the Workarea Commerce platform. This integration allows checking out
with Sezzle as well as handles displaying the relevant pricing messaging on cart and product displays. 


Getting Started
--------------------------------------------------------------------------------

This gem contains a Rails engine that must be mounted onto a host Rails application.

Then add the gem to your application's Gemfile specifying the source:

    # ...
    gem 'workarea-sezzle'
    # ...

Update your application's bundle.

    cd path/to/application
    bundle

Features
--------------------------------------------------------------------------------

This integration supports the following features:
* Adding the Sezzle payment method to payment page. 
* Support for AUTH and Capture payment intents.
* Ability to refund and capture Sezzle orders after payment.
* Admin configuration panel.

Development and Integration Notes
--------------------------------------------------------------------------------
Sezzle messaging is displayed on product detail pages (PDP) and cart pages using Sezzle JS. A merchant ID must be configured in order to display this messaging. Sezzle JS documenation can be found at [https://docs.sezzle.com/#sezzlejs](https://docs.sezzle.com/#sezzlejs).

Workarea Sezzle makes use of the following Workarea view append points for messaging display:
    
    storefront.product_pricing_details
    storefront.cart_additional_information
Make sure that any custom views in your host app have not removed these append points.


Sezzle supports two payment flows. Immediate capture of funds and an initial authorization with a capture at a later date. This behavior is controlled by the payment intent via the API when the order is sent to Sezzle. The default for this integration is authorization and capture at a later date, because this flow is used in Workarea by default. **Make sure that Sezzle payment intent matches the payment flow for your application.**

If you are hosting with Workarea Commerce Cloud make sure that you add the API endpoints to the proxy. This can be done with the Workarea CLI available to Commerce Cloud customers.


Configuration
--------------------------------------------------------------------------------

**For Workarea v3.5 and Greater** 
Sezzle can be configured via the settings section in the Workarea admin console.
Available settings are: 
* public key
* private key
* merchant ID
* test mode - will use the sandbox url instead live
* payment intent (AUTH or CAPTURE)


**For Workarea v3.0 to V3.4**
Add the following to your secrets:

    sezzle:
        api_private_key: YOUR-PUBLIC-KEY
        api_public_key: YOUR-PRIVATE-KEY
        test: true

Payment intent and merchant ID can be set in an initializer.
    
    Workarea.config.sezzle_merchant_id = 'YOUR MERCHANT ID'
    Workarea.config.sezzle_payment_action = 'AUTH'

Your merchant ID and API keys can be found in the Sezzle admin. Contact your Sezzle representative if you will be using the sandbox as it will have different API credentials for the sandbox and production environments.

Contributing
--------------------------------------------------------------------------------
We encourage contributions to this project. Please fork and submit a pull request with the minimum viable code for your bug fixes or feature enhancements.

**Found A Bug?**
Please open a Github issue with steps on how to reproduce. Be sure to follow the instructions when creating the issue. 


Documentation
--------------------------------------------------------------------------------
See [https://docs.sezzle.com](https://docs.sezzle.com) for Sezzle Documentation. 

See [https://developer.workarea.com](https://developer.workarea.com) for Workarea platform documentation.


License
--------------------------------------------------------------------------------

Workarea Sezzle is released under the MIT open source agreement.

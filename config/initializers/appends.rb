Workarea::Plugin.append_stylesheets(
  'admin.components',
  'workarea/storefront/sezzle/components/payment_icon'
)

Workarea::Plugin.append_stylesheets(
  'storefront.components',
  'workarea/storefront/sezzle/components/sezzle',
  'workarea/storefront/sezzle/components/payment_icon'
)

Workarea::Plugin.append_partials(
  'storefront.payment_method',
  'workarea/storefront/checkouts/sezzle_payment'
)

Workarea::Plugin.append_partials(
  'storefront.javascript',
  'workarea/storefront/sezzle/script'
)

Workarea::Plugin.append_partials(
  'storefront.product_pricing_details',
  'workarea/storefront/products/sezzle_widget'
)

Workarea::Plugin.append_partials(
  'storefront.cart_additional_information',
  'workarea/storefront/carts/sezzle_widget'
)

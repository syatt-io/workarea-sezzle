Workarea.configure do |config|

  config.tender_types.append(:sezzle)

  config.sezzle = ActiveSupport::Configurable::Configuration.new
  config.sezzle.api_timeout = 10
  config.sezzle.open_timeout = 10

  config.sezzle.product_config = {
    target_xpath: '#sezzle/.sezzle__prices',
    render_to_path: './',
    url_match: 'products',
    split_price_elements_on: '–'
  }

  config.sezzle.cart_config = {
    target_xpath: '#sezzle/.sezzle__prices',
    render_to_path: './',
    url_match: 'cart'
  }
end

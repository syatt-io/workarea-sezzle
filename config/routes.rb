Workarea::Storefront::Engine.routes.draw do
  get 'sezzle/start' => 'sezzle#start', as: :start_sezzle
  get 'sezzle/complete' => 'sezzle#complete', as: :complete_sezzle
  get 'sezzle/cancel' => 'sezzle#cancel', as: :cancel_sezzle
end

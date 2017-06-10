Rails.application.routes.draw do
  mount ShopifyApp::Engine, at: '/'
  root :to => 'admin#index'
  post 'generate_script' => 'admin#generate_script'
  post 'save_order'	=> 'custom#save_order'
end

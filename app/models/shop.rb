class Shop < ActiveRecord::Base
	has_many :orders
	has_many :modaloptions
  	include ShopifyApp::Shop
  	include ShopifyApp::SessionStorage
end

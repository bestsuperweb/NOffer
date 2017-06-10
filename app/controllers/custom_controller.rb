class CustomController < ApplicationController
	skip_before_filter :verify_authenticity_token

	def save_order
      
      @shop = Shop.where(:shopify_domain => params[:shop]).first

      if @shop.orders.where(:ordername => params[:ordername]).first.nil?
        order = @shop.orders.build(order_params)      
        if order.save
          render json: { status: 'success' }
        else
          render json: { status: 'failure' }
        end
      else
        render json: { status: 'success' }
      end

  end

  private

  def order_params
    params.permit(:ordername)    
  end

end

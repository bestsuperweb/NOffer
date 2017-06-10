class AdminController < ShopifyApp::AuthenticatedController
  skip_before_filter :verify_authenticity_token
  before_action      :set_option, only: [:index, :generate_script]

  def index
    @products   = ShopifyAPI::Product.all     
    
    saved_orders = Order.pluck(:ordername)
    @orders = saved_orders.collect {|order_name| ShopifyAPI::Order.where(:name => order_name).first }
    
    @dashboard = { 
                    today_count: 0, today_price: 0, 
                    yesterday_count: 0, yesterday_price: 0, 
                    week_count: 0, week_price: 0, 
                    month_count: 0, month_price: 0,
                    year_count: 0, year_price: 0,
                    all_count: 0, all_price: 0
                  }

    @orders.each {|order|
        if Date.parse(order.created_at) == Date.today
            @dashboard[:today_count] += 1
            @dashboard[:today_price] += order.total_price.to_i 
        end

        if Date.parse(order.created_at) == Date.today.prev_day
            @dashboard[:yesterday_count] += 1
            @dashboard[:yesterday_price] += order.total_price.to_i
        end

        if Date.parse(order.created_at) > ( Date.today - 7 )
            @dashboard[:week_count] += 1
            @dashboard[:week_price] += order.total_price.to_i
        end

        if Date.parse(order.created_at) > Date.today.prev_month
            @dashboard[:month_count] += 1
            @dashboard[:month_price] += order.total_price.to_i
        end

        if Date.parse(order.created_at) > Date.today.prev_year
            @dashboard[:year_count] += 1
            @dashboard[:year_price] += order.total_price.to_i
        end

        @dashboard[:all_count] += 1
        @dashboard[:all_price] += order.total_price.to_i
    }


    @metafield  = ShopifyAPI::Metafield.find(:all, :params => {:resource => "orders" })
    # meta_field  = ShopifyAPI::Metafield.new({
    #                                            :description => 'Profit Pal',
    #                                            :namespace   => 'profit_pal',
    #                                            :key         => 'tomsalinger',
    #                                            :value       => 12137891,
    #                                            :value_type  => 'integer'
    #                                        })
    # @order.add_metafield(meta_field)    
  end



  def generate_script
    
    option      = params[:option]
    background  = ActionController::Base.helpers.asset_path('background.png')
    background1 = ActionController::Base.helpers.asset_path('background1.png')

    theme       = ShopifyAPI::Theme.where(:role => 'main').first
  
    case option

      when 'option1'

        styleContent = "@import url('https://fonts.googleapis.com/css?family=Open+Sans');
                        @import url('https://fonts.googleapis.com/css?family=Roboto');
                        @import url('https://fonts.googleapis.com/css?family=Lato');
                        @import url('https://fonts.googleapis.com/css?family=Josefin+Sans');
                        @import url('https://fonts.googleapis.com/css?family=Lobster');
                        @import url('https://fonts.googleapis.com/css?family=Dancing+Script');
                        @import url('https://fonts.googleapis.com/css?family=Playfair+Display');
                        @import url('https://fonts.googleapis.com/css?family=Chewy');
                        @import url('https://fonts.googleapis.com/css?family=Quicksand');
                        @import url('https://fonts.googleapis.com/css?family=Satisfy');
                        @import url('https://fonts.googleapis.com/css?family=Oswald');
                        #tsmodal-fade{position: fixed; top: 0; width: 100%;  height: 100%; z-index: 1000; background: rgba(0,0,0,.5); left: 0;} 
                        #tsmodal{ text-align: center; padding: 10px; border: 5px double #{params[:bd_color]}; width: 555px; height: 245px; box-shadow: 0 0 5px grey; background-image: url(#{background}); background-color: #{params[:bg_color]}; color: #{params[:main_color]}; font-family: #{params[:main_font]}; background-repeat: no-repeat;  background-size: contain;  background-position: right top; margin: auto; margin-top: 10%; border-radius: 5px; }
                        div.time-left{ margin-top: -60px; padding: 14px;  text-align: center;  font-size: 20px;  border-radius: 10px 10px 0 0;  box-shadow: 0 0 5px grey;  font-weight: 900;  width: 70%;  margin-left: auto;  margin-right: auto;  background: #{params[:main_color]}; color: #{params[:timer_color]}; font-family: #{params[:timer_font]}; }
                        div.time-left span{ font-size: 28px; }
                        div.main-content { margin-top: -5px; } 
                        div.right-box, div.left-box{ height: 150px; position: relative; width: 46%; padding: 10px 5px; }
                        div.right-box{ float: right;  background-color: #{params[:main_color]}; border-radius: 3px; color: #{params[:txt_color]}; opacity: .8; }
                        div.left-box{ float: left; border-radius: 3px; }
                        a#btn{ background-color: #{params[:main_color]}; color: #{params[:btn_color]}; font-family: #{params[:btn_font]}; border-radius: 3px; padding: 10px 20px; box-shadow: 0 0 3px gray; text-decoration: none; display: inline-block; margin-top: 20px; font-size: 22px; }
                        p.detailed-upsell{ font-size: #{params[:font_size]}px; color: #{params[:txt_color]}; }
                        div#close{ position: relative; left: 290px; top: -10px;  background: #{params[:main_color]};  display: inline-block;  border-radius: 50%;  padding: 2px 6px;  color: #fff;  border: 3px solid #fff;  box-shadow: 0 0 3px grey;  cursor: pointer; transition: all 1s;}
                        div#close:hover{ transform: rotate(360deg)scale(1.3); }
                        .pop-product-img{ transition: all 2s ease; } .pop-product-img:hover{ transform: #{params[:animation]}; }"
        jsContent    = "$(function() {
                          $('#tsmodal').addClass('animated bounceInDown');
                          $('#close').on('click', function(){
                              $('div#tsmodal-fade').addClass('animated slideOutDown');
                            });
                          var hms = '#{params[:time_left]}';   
                          var a = hms.split(':');
                          var seconds = (+a[0]) * 60 * 60 + (+a[1]) * 60 + (+a[2]);
                          var selectedSeconds = new Date().getTime() + seconds*1000;    
                          $('div.time-left span').countdown(selectedSeconds, {elapse: true})
                          .on('update.countdown', function(event) {
                            var $this = $(this);
                            if (event.elapsed) {
                              $('div#tsmodal-fade').addClass('animated zoomOut');
                            } else {
                              $this.html(event.strftime('%H:%M:%S'));
                            }
                          });
                          $('a#btn').on('click', function(){
                              var redirect_url = $(this).attr('data-link');
                              $.ajax({
                                  url: '#{save_order_url}',
                                  data: { ordername: $(this).attr('data-order'), shop: '#{@shop.shopify_domain}' },
                                  type: 'post',
                                  success: function(response){
                                        if(response.status == 'success'){
                                            window.top.location.href = redirect_url;
                                          }else{
                                            $('div#tsmodal-fade').addClass('animated slideOutDown');
                                          }
                                    }
                                });
                          });

                       });"

        result = "<link href='{{'tspopup.css' | asset_url}}' rel='stylesheet' type='text/css' media='all' />
                  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.5.2/animate.min.css'>
                  <script src='https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js'></script>
                  <script src='https://cdnjs.cloudflare.com/ajax/libs/jquery.countdown/2.2.0/jquery.countdown.min.js'></script>
                  <script src='{{'tspopup.js' | asset_url }}' type='text/javascript' ></script>
                  <div id='tsmodal-fade'> <div id='tsmodal'>
                  <div class='time-left'>  OFFER ENDS: <span>#{params[:time_left]}</span> </div>
                  <div id='close'>X</div>
                  <div class='main-content'>
                  <div class='left-box'>
                    <a href='https://#{ShopifyAPI::Shop.current.domain}/products/#{params[:product].split(':::')[1]}' >
                      <img src='#{params[:product].split(':::')[0]}' class='pop-product-img' width='70%' />
                    </a>
                  </div>
                  <div class='right-box'>
                  <p class='detailed-upsell' >#{params[:main_text]}</p>
                  </div>
                  </div>
                  <div style='clear:both;'></div>
                  <a href='#' data-link='#{params[:btn_link]}' id='btn' data-order='{{order.name}}'>#{params[:btn_txt]}</a>
                  </div> </div>"

      when 'option2'
        
        styleContent = "@import url('https://fonts.googleapis.com/css?family=Open+Sans');
                        @import url('https://fonts.googleapis.com/css?family=Roboto');
                        @import url('https://fonts.googleapis.com/css?family=Lato');
                        @import url('https://fonts.googleapis.com/css?family=Josefin+Sans');
                        @import url('https://fonts.googleapis.com/css?family=Lobster');
                        @import url('https://fonts.googleapis.com/css?family=Dancing+Script');
                        @import url('https://fonts.googleapis.com/css?family=Playfair+Display');
                        @import url('https://fonts.googleapis.com/css?family=Chewy');
                        @import url('https://fonts.googleapis.com/css?family=Quicksand');
                        @import url('https://fonts.googleapis.com/css?family=Satisfy');
                        @import url('https://fonts.googleapis.com/css?family=Oswald');
                        #tsmodal-fade{position: fixed; top: 0; width: 100%;  height: 100%; z-index: 1000; background: rgba(0,0,0,.5); left: 0;} 
                        #tsmodal{ text-align: center; padding: 10px; border: 5px double #{params[:bd_color]}; width: 555px; height: 245px; box-shadow: 0 0 5px grey; background-image: url(#{background}); background-color: #{params[:bg_color]}; color: #{params[:main_color]}; font-family: #{params[:main_font]}; background-repeat: no-repeat;  background-size: contain;  background-position: right top; margin: auto; margin-top: 10%; border-radius: 5px; }
                        div.time-left{ margin-top: -60px; padding: 14px;  text-align: center;  font-size: 20px;  border-radius: 10px 10px 0 0;  box-shadow: 0 0 5px grey;  font-weight: 900;  width: 70%;  margin-left: auto;  margin-right: auto;  background: #{params[:main_color]}; color: #{params[:timer_color]}; font-family: #{params[:timer_font]}; }
                        div.time-left span{ font-size: 28px; }
                        div.main-content { margin-top: -5px; } 
                        div.right-box, div.left-box{ height: 150px; position: relative; width: 46%; padding: 10px 5px; }
                        div.right-box{ float: right; }
                        div.left-box{ float: left; border-radius: 3px; }
                        div.use-code{  font-size: 20px;  font-weight: 900;  padding: 5px 10px;  border: 2px solid #{params[:bd_color]};  border-radius: 3px;  word-wrap: break-word;  max-height: 80px;  overflow: hidden;  display: inline-block; }
                        div.use-code p { transform: scaleY(1.8); margin: 0; color: #{params[:txt_color]}; }
                        div.discount { padding: 8px 30px;  color: #fff;  font-size: 25px;  border-radius: 4px;  display: inline-block;  line-height: 15px;  opacity: .9; background-color: #{params[:main_color]}; margin-top: 5px;}
                        div.discount table td{ padding-left: 0 !important; }
                        a#btn{ background-color: #{params[:main_color]}; color: #{params[:btn_color]}; font-family: #{params[:btn_font]}; border-radius: 3px; padding: 10px 20px; box-shadow: 0 0 3px gray; text-decoration: none; display: inline-block; margin-top: 20px; font-size: 22px; }
                        p.detailed-upsell{ font-size: #{params[:font_size]}px; color: #{params[:txt_color]}; }
                        div#close{ position: relative; left: 290px; top: -10px;  background: #{params[:main_color]};  display: inline-block;  border-radius: 50%;  padding: 2px 6px;  color: #fff;  border: 3px solid #fff;  box-shadow: 0 0 3px grey;  cursor: pointer; transition: all 1s;}
                        div#close:hover{ transform: rotate(360deg)scale(1.3); }"
        jsContent    = "$(function() {
                          $('#tsmodal').addClass('animated bounceInDown');
                          $('#close').on('click', function(){
                              $('div#tsmodal-fade').addClass('animated slideOutDown');
                            });
                          var hms = '#{params[:time_left]}';   
                          var a = hms.split(':');
                          var seconds = (+a[0]) * 60 * 60 + (+a[1]) * 60 + (+a[2]);
                          var selectedSeconds = new Date().getTime() + seconds*1000;    
                          $('div.time-left span').countdown(selectedSeconds, {elapse: true})
                          .on('update.countdown', function(event) {
                            var $this = $(this);
                            if (event.elapsed) {
                              $('div#tsmodal-fade').addClass('animated zoomOut');
                            } else {
                              $this.html(event.strftime('%H:%M:%S'));
                            }
                          });
                          $('a#btn').on('click', function(){
                              var redirect_url = $(this).attr('data-link');
                              $.ajax({
                                  url: '#{save_order_url}',
                                  data: { ordername: $(this).attr('data-order'), shop: '#{@shop.shopify_domain}' },
                                  type: 'post',
                                  success: function(response){
                                        if(response.status == 'success'){
                                            window.top.location.href = redirect_url;
                                          }else{
                                            $('div#tsmodal-fade').addClass('animated slideOutDown');
                                          }
                                    }
                                });
                          });

                       });"

        result = "<link href='{{'tspopup.css' | asset_url}}' rel='stylesheet' type='text/css' media='all' />
                  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.5.2/animate.min.css'>
                  <script src='https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js'></script>
                  <script src='https://cdnjs.cloudflare.com/ajax/libs/jquery.countdown/2.2.0/jquery.countdown.min.js'></script>
                  <script src='{{'tspopup.js' | asset_url }}' type='text/javascript' ></script>
                  <div id='tsmodal-fade'> <div id='tsmodal'>
                  <div class='time-left'>  OFFER ENDS: <span>#{params[:time_left]}</span> </div>
                  <div id='close'>X</div>
                  <div class='main-content'>
                  <div class='left-box'>
                    <p class='detailed-upsell'>#{params[:main_text]}</p>
                  </div>
                  <div class='right-box'>
                    <div class='use-code'><p>USE CODE: #{params[:use_code]}</p></div>
                    <div class='discount'>
                    <table>
                      <tbody><tr>
                        <td style='font-size: 40px;' >#{params[:percentage]}</td>
                        <td >#{params[:distype]}<br><span style='font-size: 15px;''>off</span></td>
                      </tr>
                    </tbody></table>
                    </div>
                  </div>
                  </div>
                  <div style='clear:both;'></div>
                  <a href='#' data-link='#{params[:btn_link]}' data-order='{{order.name}}' id='btn'>#{params[:btn_txt]}</a>
                  </div> </div>"

      when 'option3'
        
        styleContent = "@import url('https://fonts.googleapis.com/css?family=Open+Sans');
                        @import url('https://fonts.googleapis.com/css?family=Roboto');
                        @import url('https://fonts.googleapis.com/css?family=Lato');
                        @import url('https://fonts.googleapis.com/css?family=Josefin+Sans');
                        @import url('https://fonts.googleapis.com/css?family=Lobster');
                        @import url('https://fonts.googleapis.com/css?family=Dancing+Script');
                        @import url('https://fonts.googleapis.com/css?family=Playfair+Display');
                        @import url('https://fonts.googleapis.com/css?family=Chewy');
                        @import url('https://fonts.googleapis.com/css?family=Quicksand');
                        @import url('https://fonts.googleapis.com/css?family=Satisfy');
                        @import url('https://fonts.googleapis.com/css?family=Oswald');
                        #tsmodal-fade{position: fixed; top: 0; width: 100%;  height: 100%; z-index: 1000; background: rgba(0,0,0,.5); left: 0;} 
                        #tsmodal{ text-align: center; padding: 10px; border: 5px double #{params[:bd_color]}; width: 555px; height: 245px; box-shadow: 0 0 5px grey; background-image: url(#{background}); background-color: #{params[:bg_color]}; color: #{params[:main_color]}; font-family: #{params[:main_font]}; background-repeat: no-repeat;  background-size: contain;  background-position: right top; margin: auto; margin-top: 10%; border-radius: 5px; }
                        div.time-left{ margin-top: -60px; padding: 14px;  text-align: center;  font-size: 20px;  border-radius: 10px 10px 0 0;  box-shadow: 0 0 5px grey;  font-weight: 900;  width: 70%;  margin-left: auto;  margin-right: auto;  background: #{params[:main_color]}; color: #{params[:timer_color]}; font-family: #{params[:timer_font]}; }
                        div.time-left span{ font-size: 28px; }
                        div.main-content { margin-top: -5px; } 
                        div.discount { padding: 8px 30px;  color: #fff;  font-size: 25px;  border-radius: 4px;  display: inline-block;  line-height: 15px;  opacity: .9; background-color: #{params[:main_color]}; position: absolute;  z-index: 10;  right: 20px; top: 10px; }
                        div.discount table td{ padding-left: 0 !important; }
                        div#close{ position: relative; left: 290px; top: -10px;  background: #{params[:main_color]};  display: inline-block;  border-radius: 50%;  padding: 2px 6px;  color: #fff;  border: 3px solid #fff;  box-shadow: 0 0 3px grey;  cursor: pointer; transition: all 1s;}
                        div#close:hover{ transform: rotate(360deg)scale(1.3); }
                        a#btn{ background-color: #{params[:main_color]}; color: #{params[:btn_color]}; font-family: #{params[:btn_font]}; border-radius: 3px; padding: 10px 20px; box-shadow: 0 0 3px gray; text-decoration: none; font-size: 22px; position: relative; bottom: 50px;}
                        div.box{ position: relative; width: 33%; float: left; } 
                        .pop-product-img{ transition: all 2s ease; } .pop-product-img:hover{ transform: #{params[:animation]}; }"
        jsContent    = "$(function() {
                          $('#tsmodal').addClass('animated pulse');
                          $('#close').on('click', function(){
                              $('div#tsmodal-fade').addClass('animated slideOutDown');
                            });
                          var hms = '#{params[:time_left]}';   
                          var a = hms.split(':');
                          var seconds = (+a[0]) * 60 * 60 + (+a[1]) * 60 + (+a[2]);
                          var selectedSeconds = new Date().getTime() + seconds*1000;    
                          $('div.time-left span').countdown(selectedSeconds, {elapse: true})
                          .on('update.countdown', function(event) {
                            var $this = $(this);
                            if (event.elapsed) {
                              $('div#tsmodal-fade').addClass('animated zoomOut');
                            } else {
                              $this.html(event.strftime('%H:%M:%S'));
                            }
                          });
                          $('a#btn').on('click', function(){
                              var redirect_url = $(this).attr('data-link');
                              $.ajax({
                                  url: '#{save_order_url}',
                                  data: { ordername: $(this).attr('data-order'), shop: '#{@shop.shopify_domain}' },
                                  type: 'post',
                                  success: function(response){
                                        if(response.status == 'success'){
                                            window.top.location.href = redirect_url;
                                          }else{
                                            $('div#tsmodal-fade').addClass('animated slideOutDown');
                                          }
                                    }
                                });
                          });

                       });"

        

        result = "<link href='{{'tspopup.css' | asset_url}}' rel='stylesheet' type='text/css' media='all' />
                  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.5.2/animate.min.css'>
                  <script src='https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js'></script>
                  <script src='https://cdnjs.cloudflare.com/ajax/libs/jquery.countdown/2.2.0/jquery.countdown.min.js'></script>
                  <script src='{{'tspopup.js' | asset_url }}' type='text/javascript' ></script>
                  <div id='tsmodal-fade'> <div id='tsmodal'>
                  <div class='time-left'>  OFFER ENDS: <span>#{params[:time_left]}</span> </div>
                  <div id='close'>X</div>
                  <div class='discount'>
                    <table>
                      <tbody><tr>
                        <td style='font-size: 40px;' >#{params[:percentage]}</td>
                        <td >#{params[:distype]}<br><span style='font-size: 15px;''>off</span></td>
                      </tr>
                    </tbody></table>
                  </div>
                  <div class='main-content'>
                  <div class='box'>
                    <a href='https://#{ShopifyAPI::Shop.current.domain}/products/#{params[:product].split(':::')[1]}' >
                      <img src='#{params[:product].split(':::')[0]}' class='pop-product-img'  />
                    </a>
                  </div>
                  <div class='box'>
                    <a href='https://#{ShopifyAPI::Shop.current.domain}/products/#{params[:product1].split(':::')[1]}' >
                      <img src='#{params[:product1].split(':::')[0]}' class='pop-product-img' width='85%' />
                    </a>
                  </div>
                  <div class='box'>
                    <a href='https://#{ShopifyAPI::Shop.current.domain}/products/#{params[:product2].split(':::')[1]}' >
                      <img src='#{params[:product2].split(':::')[0]}' class='pop-product-img' />
                    </a>
                  </div>
                  </div>
                  <a href='#' data-link='#{params[:btn_link]}' data-order='{{order.name}}' id='btn'>#{params[:btn_txt]}</a>
                  </div> </div>"

      when 'option4'
        
        styleContent = "@import url('https://fonts.googleapis.com/css?family=Open+Sans');
                        @import url('https://fonts.googleapis.com/css?family=Roboto');
                        @import url('https://fonts.googleapis.com/css?family=Lato');
                        @import url('https://fonts.googleapis.com/css?family=Josefin+Sans');
                        @import url('https://fonts.googleapis.com/css?family=Lobster');
                        @import url('https://fonts.googleapis.com/css?family=Dancing+Script');
                        @import url('https://fonts.googleapis.com/css?family=Playfair+Display');
                        @import url('https://fonts.googleapis.com/css?family=Chewy');
                        @import url('https://fonts.googleapis.com/css?family=Quicksand');
                        @import url('https://fonts.googleapis.com/css?family=Satisfy');
                        @import url('https://fonts.googleapis.com/css?family=Oswald');
                        #tsmodal-fade{position: fixed; top: 0; width: 100%;  height: 100%; z-index: 1000; background: rgba(0,0,0,.5); left: 0;} 
                        #tsmodal{ text-align: center; padding: 10px; border: 5px double #{params[:bd_color]}; width: 555px; height: 245px; box-shadow: 0 0 5px grey; background-image: url(#{background1}); background-color: #{params[:bg_color]}; color: #{params[:main_color]}; font-family: #{params[:main_font]}; background-repeat: no-repeat;  background-size: contain;  background-position: right top; margin: auto; margin-top: 10%; border-radius: 5px; }
                        div.time-left{ margin-top: -60px; padding: 14px; text-align: center; font-size: 20px; border-radius: 10px 10px 0 0;  box-shadow: 0 0 5px grey; font-weight: 900; width: 70%; margin-left: auto;  margin-right: auto; background: #{params[:main_color]}; color: #{params[:timer_color]}; font-family: #{params[:timer_font]}; }
                        div.time-left span{ font-size: 28px; }
                        div.main-content { margin-top: -5px; } 
                        div.right-box, div.left-box{ height: 150px; position: relative; width: 46%; padding: 10px 5px; }
                        div.right-box{ float: right; opacity: .8; }
                        div.left-box{ float: left; border-radius: 3px; }
                        a#btn{ background-color: #{params[:main_color]}; color: #{params[:btn_color]}; font-family: #{params[:btn_font]}; border-radius: 3px; padding: 10px 20px; box-shadow: 0 0 3px gray; text-decoration: none; display: inline-block; margin-top: 20px; font-size: 22px; }
                        p.detailed-upsell{ color:#{params[:txt_color]}; font-size: #{params[:font_size]}px; }
                        div.use-code{  font-size: 20px; font-weight: 900; padding: 10px; border: 2px solid #{params[:bd_color]}; border-radius: 3px;  word-wrap: break-word; max-height: 80px; overflow: hidden; display: inline-block; margin-top: 20px; color: #{params[:txt_color]};}
                        div.use-code p { color: #{params[:txt_color]}; }
                        div.discount { color: #fff; font-size: 25px; border-radius: 4px; display: inline-block; line-height: 15px; border-radius: 50%; border: 5px solid #fff; padding: 30px 15px; box-shadow: -3px 5px 1px #dbdddf; margin-top: 15%; margin-left: -65%; background-color: #{params[:main_color]};}
                        div.discount table td{ padding-left: 0 !important; }
                        div#close{ position: relative; left: 290px; top: -10px;  background: #{params[:main_color]};  display: inline-block;  border-radius: 50%;  padding: 2px 6px;  color: #fff;  border: 3px solid #fff;  box-shadow: 0 0 3px grey;  cursor: pointer; transition: all 1s;}
                        div#close:hover{ transform: rotate(360deg)scale(1.3); }"
        jsContent    = "$(function() {
                          $('#tsmodal').addClass('animated tada');
                          $('#close').on('click', function(){
                              $('div#tsmodal-fade').addClass('animated slideOutDown');
                            });
                          var hms = '#{params[:time_left]}';   
                          var a = hms.split(':');
                          var seconds = (+a[0]) * 60 * 60 + (+a[1]) * 60 + (+a[2]);
                          var selectedSeconds = new Date().getTime() + seconds*1000;    
                          $('div.time-left span').countdown(selectedSeconds, {elapse: true})
                          .on('update.countdown', function(event) {
                            var $this = $(this);
                            if (event.elapsed) {
                              $('div#tsmodal-fade').addClass('animated zoomOut');
                            } else {
                              $this.html(event.strftime('%H:%M:%S'));
                            }
                          });
                          $('a#btn').on('click', function(){
                              var redirect_url = $(this).attr('data-link');
                              $.ajax({
                                  url: '#{save_order_url}',
                                  data: { ordername: $(this).attr('data-order'), shop: '#{@shop.shopify_domain}' },
                                  type: 'post',
                                  success: function(response){
                                        if(response.status == 'success'){
                                            window.top.location.href = redirect_url;
                                          }else{
                                            $('div#tsmodal-fade').addClass('animated slideOutDown');
                                          }
                                    }
                                });
                          });

                       });"

        result = "<link href='{{'tspopup.css' | asset_url}}' rel='stylesheet' type='text/css' media='all' />
                  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.5.2/animate.min.css'>
                  <script src='https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js'></script>
                  <script src='https://cdnjs.cloudflare.com/ajax/libs/jquery.countdown/2.2.0/jquery.countdown.min.js'></script>
                  <script src='{{'tspopup.js' | asset_url }}' type='text/javascript' ></script>
                  <div id='tsmodal-fade'> <div id='tsmodal'>
                  <div class='time-left'>  OFFER ENDS: <span>#{params[:time_left]}</span> </div>
                  <div id='close'>X</div>
                  <div class='main-content'>
                  <div class='left-box'>
                    <p class='detailed-upsell'>#{params[:main_text]}</p>
                    <div class='use-code'>USE CODE: #{params[:use_code]}</div>
                  </div>
                  <div class='right-box'>
                    <div class='discount'>
                      <table><tbody><tr>
                          <td style='font-size: 40px;' >#{params[:percentage]}</td>
                          <td >#{params[:distype]}<br><span style='font-size: 15px;''>off</span></td>
                      </tr></tbody></table>
                    </div>
                  </div>
                  </div>
                  <div style='clear:both;'></div>
                  <a href='#' data-link='#{params[:btn_link]}' id='btn'>#{params[:btn_txt]}</a>
                  </div> </div>"

    end    
    

    begin

      style       = ShopifyAPI::Asset.find( 'assets/tspopup.css', :theme_id => theme.id )
      style.value = styleContent

      js          = ShopifyAPI::Asset.find( 'assets/tspopup.js', :theme_id => theme.id )
      js.value    = jsContent

    rescue
      
      style       = ShopifyAPI::Asset.new(:theme_id => theme.id, :key => "assets/tspopup.css", :value => styleContent )
      js          = ShopifyAPI::Asset.new(:theme_id => theme.id, :key => "assets/tspopup.js", :value => jsContent )

    end
    
    # render json: { result: theme.id }
    
    if style.save and js.save
      if @shop.modaloptions.first.nil?
        @option = @shop.modaloptions.build(option_params)
        @option.save
      else
        @option.update(option_params)
      end      
      render json: { status: 'success', result: result }
    else
      render json: { status: 'failure' }
    end

  end  

  private
  def set_option
      @shop = Shop.where(:shopify_domain => ShopifyAPI::Shop.current.domain).first

      if @shop.modaloptions.first.nil?
        @option = nil
      else
        @option = @shop.modaloptions.first
      end
  end
  # Never trust parameters from the scary internet, only allow the white list through.
  def option_params
      params.permit( 
        :option,
        :main_text,
        :txt_color,
        :time_left,
        :main_font,
        :font_size,
        :timer_color,
        :timer_font,      
        :timer_text,
        :timer_size,
        :btn_link,
        :btn_color,     
        :main_color,
        :btn_txt,
        :btn_font,
        :bg_color,
        :bd_color,
        :percentage,
        :distype,
        :use_code,
        :product,
        :product1,
        :product2,
        :animation,
        :main_title,
        :main_t_color,
        :main_t_size,
        :main_t_font,
        :ribbon_text,
        :ribbon_color,
        :rt_color,
        :ribbon_font,
        :badge_size,
        :badge_font,
        :badge_color,
        :bt_color,
        :corner_color,
        :pb_txt,
        :pb_color,
        :pb_bg_color,
        :pb_font,
        :pb_mb_pos,
        :pb_desk_pos
      )
  end  

end
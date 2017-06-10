class CreateModaloptions < ActiveRecord::Migration
  def change
    create_table :modaloptions do |t|
            t.string :option
            t.string :main_text
            t.string :txt_color
            t.string :time_left
            t.string :main_font
            t.string :font_size
            t.string :timer_color
            t.string :timer_font      
            t.string :timer_text
            t.string :timer_size
            t.string :btn_link
            t.string :btn_color     
            t.string :main_color
            t.string :btn_txt
            t.string :btn_font
            t.string :bg_color
            t.string :bd_color
            t.string :percentage
            t.string :distype
            t.string :use_code
            t.string :product
            t.string :product1
            t.string :product2
            t.string :animation
            t.string :main_title
            t.string :main_t_color
            t.string :main_t_size
            t.string :main_t_font
            t.string :ribbon_text
            t.string :ribbon_color
            t.string :rt_color
            t.string :ribbon_font
            t.string :ribbon_size
            t.string :badge_size
            t.string :badge_font
            t.string :badge_color
            t.string :bt_color
            t.string :corner_color
            t.string :pb_txt
            t.string :pb_color
            t.string :pb_bg_color
            t.string :pb_font
            t.string :pb_mb_pos
            t.string :pb_desk_pos
            
            t.references :shop, index: true, foreign_key: true

            t.timestamps null: false
    end
    add_index :modaloptions, [:shop_id, :created_at]
  end

end

class AddBtnsizeToModaloptions < ActiveRecord::Migration
  def change
    add_column :modaloptions, :btn_size, :string
  end
end

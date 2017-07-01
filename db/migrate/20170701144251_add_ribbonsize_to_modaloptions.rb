class AddRibbonsizeToModaloptions < ActiveRecord::Migration
  def change
    add_column :modaloptions, :ribbon_size, :string
  end
end

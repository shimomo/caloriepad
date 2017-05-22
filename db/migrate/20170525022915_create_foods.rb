class CreateFoods < ActiveRecord::Migration[5.1]
  def change
    create_table :foods do |t|
      t.integer :food_id, :null => false
      t.string :ja_food_name, :null => false
      t.string :en_food_name, :null => false
      t.string :food_per, :null => false
      t.string :food_calorie, :null => false
      t.timestamps
    end
  end
end

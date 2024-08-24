class CreateBuildings < ActiveRecord::Migration[7.1]
  def change
    create_table :buildings, id: :uuid do |t|
      t.string :name, null: false
      t.string :address, null: false

      t.timestamps
    end
  end
end

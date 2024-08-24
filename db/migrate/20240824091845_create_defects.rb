class CreateDefects < ActiveRecord::Migration[7.1]
  def change
    create_table :defects, id: :uuid do |t|
      t.string :name, null: false
      t.references :building, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end

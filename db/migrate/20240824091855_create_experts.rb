class CreateExperts < ActiveRecord::Migration[7.1]
  def change
    create_table :experts, id: :uuid do |t|
      t.references :building, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false

      t.timestamps
    end
  end
end

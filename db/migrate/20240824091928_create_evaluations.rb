class CreateEvaluations < ActiveRecord::Migration[7.1]
  def change
    create_table :evaluations, id: :uuid do |t|
      t.references :defect, null: false, foreign_key: true, type: :uuid
      t.references :expert, null: false, foreign_key: true, type: :uuid
      t.decimal :rating, precision: 3, scale: 2, null: false

      t.timestamps
      t.index [:defect_id, :expert_id], unique: true
    end
  end
end

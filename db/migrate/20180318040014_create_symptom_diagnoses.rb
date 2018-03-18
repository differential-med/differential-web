class CreateSymptomDiagnoses < ActiveRecord::Migration[5.2]
  def change
    create_table :symptom_diagnoses do |t|
      t.string :diagnosis_id
      t.text :symptom_id

      t.timestamps
    end
  end
end

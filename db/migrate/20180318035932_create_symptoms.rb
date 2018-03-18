class CreateSymptoms < ActiveRecord::Migration[5.2]
  def change
    create_table :symptoms, id: false do |t|
      t.primary_key :id, :string
      t.string :name
      t.text :summary

      t.timestamps
    end
  end
end

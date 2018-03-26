class Diagnosis < ApplicationRecord
  has_many :symptom_diagnoses
  has_many :symptoms, through: :symptom_diagnoses
end

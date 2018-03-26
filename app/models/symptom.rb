class Symptom < ApplicationRecord
  has_many :symptom_diagnoses
  has_many :diagnoses, through: :symptom_diagnoses
end

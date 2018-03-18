class Symptom < ApplicationRecord
  has_many :diagnoses, through: :symptom_diagnoses
end

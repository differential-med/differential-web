class SymptomDiagnosis < ApplicationRecord
  has_one :diagnosis
  has_one :symptom
end

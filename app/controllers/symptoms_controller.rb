class SymptomsController < ApplicationController
  def show
    @symptom = Symptom.find(params[:id])
  end

  def random
    random_offset = rand(Symptom.count)
    symptom = Symptom.offset(random_offset).first

    redirect_to(symptom_path(symptom))
  end
end

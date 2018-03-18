class SymptompsController < ApplicationController
  def show
    @symptom = Symptom.find(params[:id])
  end
end

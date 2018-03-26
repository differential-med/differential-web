# http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  get "about" => "main#about"

  get "differential-of-:id" => "symptoms#show", as: :symptom
  get "random-symptom" => "symptoms#random"

  root "main#home"
end

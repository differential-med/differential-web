# http://guides.rubyonrails.org/routing.html
#
Rails.application.routes.draw do
  get "differential-of-:id" => "symptoms#show"
end

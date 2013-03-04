LetsRails::Application.routes.draw do
  get "/deals" => "deals#index", as: "deals"
  get "/deals/:id" => "deals#show", as: "deal"

  get "/deals/:deal_id/purchases/new" => "purchases#new", as: "new_deal_purchase"
  post "/deals/:deal_id/purchases" => "purchases#create", as: "deal_purchases"

  get "/registro" => "people#new", as: "sign_up"
  root :to => "deals#index"
end

Rails.application.routes.draw do
  match '/rhoconnect/authenticate' => Rhoconnectrb::Authenticate, via: [:post]
  match '/rhoconnect/query' => Rhoconnectrb::Query, via: [:post]
  match '/rhoconnect/create' => Rhoconnectrb::Create, via: [:post]
  match '/rhoconnect/update' => Rhoconnectrb::Update, via: [:post]
  match '/rhoconnect/delete' => Rhoconnectrb::Delete, via: [:post]
end
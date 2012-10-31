Rails.application.routes.draw do
  match '/rhoconnect/authenticate' => Rhoconnectrb::Authenticate
  match '/rhoconnect/query' => Rhoconnectrb::Query
  match '/rhoconnect/create' => Rhoconnectrb::Create
  match '/rhoconnect/update' => Rhoconnectrb::Update
  match '/rhoconnect/delete' => Rhoconnectrb::Delete
end
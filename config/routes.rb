Rails.application.routes.draw do
  match '/rhoconnectrb/authenticate' => Rhoconnectrb::Authenticate
  match '/rhoconnectrb/query' => Rhoconnectrb::Query
  match '/rhoconnectrb/create' => Rhoconnectrb::Create
  match '/rhoconnectrb/update' => Rhoconnectrb::Update
  match '/rhoconnectrb/delete' => Rhoconnectrb::Delete
end
Rails.application.routes.draw do
  match '/rhoconnect/authenticate' => Rhoconnect::Authenticate
  match '/rhoconnect/query' => Rhoconnect::Query
  match '/rhoconnect/create' => Rhoconnect::Create
  match '/rhoconnect/update' => Rhoconnect::Update
  match '/rhoconnect/delete' => Rhoconnect::Delete
end
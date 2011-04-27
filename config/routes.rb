Rails.application.routes.draw do
  match '/rhosync/authenticate' => Rhosync::Authenticate
  match '/rhosync/query' => Rhosync::Query
  match '/rhosync/create' => Rhosync::Create
  match '/rhosync/update' => Rhosync::Update
  match '/rhosync/delete' => Rhosync::Delete
end
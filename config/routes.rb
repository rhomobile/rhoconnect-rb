Rails.application.routes.draw do
  match '/rhosync/authenticate' => Rhosync::Authenticate
  match '/rhosync/query' => Rhosync::Query
  match '/rhosync/create' => Rhosync::Create
end
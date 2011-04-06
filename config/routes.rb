Rails.application.routes.draw do
  match '/rhosync/authenticate' => Rhosync::Authenticate
  match '/rhosync/query' => Rhosync::Query
end
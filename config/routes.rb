Rails.application.routes.draw do
  match '/rhosync/authenticate' => Rhosync::Authenticate
end
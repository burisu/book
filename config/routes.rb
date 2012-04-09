Book::Application.routes.draw do
  resources :event_natures

  match 'nom-utilisateur-perdu' => 'people#lost_login', :as => :lost_login
  match 'mot-de-passe-perdu' => 'people#lost_password', :as => :lost_password
  match 'inscription' => 'people#signup', :as => :signup
  resource :session
  resources :people
  resources :group_kinships
  resources :person_interventions
  resources :person_intervention_natures
  resources :group_interventions
  resources :group_intervention_natures
  resources :group_natures
  resources :organizations
  resources :events

  root :to => 'people#index'
end

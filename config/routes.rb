Book::Application.routes.draw do
  match 'nom-utilisateur-perdu' => 'people#lost_login', :as => :lost_login
  match 'mot-de-passe-perdu' => 'people#lost_password', :as => :lost_password
  match 'inscription' => 'people#signup', :as => :signup
  resource :session
  resources :activities
  resources :events
  resources :event_natures
  resources :groups
  resources :group_interventions
  resources :group_intervention_natures
  resources :group_kinships
  resources :group_natures
  resources :honours
  resources :honour_natures
  resources :person_interventions
  resources :person_intervention_natures
  resources :organigram_professions
  resources :organigrams
  resources :organizations
  resources :people do
    collection do
      get :list
    end
  end
  resources :person_contacts
  resources :person_contact_natures
  resources :person_honours
  resources :sectors
  root :to => 'people#index'
end

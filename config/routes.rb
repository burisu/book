Book::Application.routes.draw do
  match 'nom-utilisateur-perdu' => 'people#lost_login', :as => :lost_login
  match 'mot-de-passe-perdu' => 'people#lost_password', :as => :lost_password
  match 'inscription' => 'people#signup', :as => :signup
  resource :session
  #[ROUTES[ Do not edit these lines directly.
  resources :activities do
    get :list, :on => :collection
  end
  resources :answers do
    get :list, :on => :collection
    get :list_items, :on => :collection
  end
  resources :answer_items do
    get :list, :on => :collection
  end
  resources :articles do
    get :list, :on => :collection
  end
  resources :configurations do
    get :list, :on => :collection
  end
  resources :events do
    get :list, :on => :collection
  end
  resources :event_natures do
    get :list, :on => :collection
    get :list_events, :on => :collection
  end
  resources :groups do
    get :list, :on => :collection
    get :list_interventions, :on => :collection
  end
  resources :group_interventions do
    get :list, :on => :collection
  end
  resources :group_intervention_natures do
    get :list, :on => :collection
    get :list_group_interventions, :on => :collection
  end
  resources :group_kinships do
    get :list, :on => :collection
  end
  resources :group_natures do
    get :list, :on => :collection
    get :list_groups, :on => :collection
  end
  resources :guests do
    get :list, :on => :collection
  end
  resources :honours do
    get :list, :on => :collection
  end
  resources :honour_natures do
    get :list, :on => :collection
    get :list_honours, :on => :collection
  end
  resources :images do
    get :list, :on => :collection
  end
  resources :mandates do
    get :list, :on => :collection
  end
  resources :mandate_natures do
    get :list, :on => :collection
    get :list_mandate, :on => :collection
  end
  resources :members do
    get :list, :on => :collection
  end
  resources :organigrams do
    get :list, :on => :collection
    get :list_professions, :on => :collection
  end
  resources :organigram_professions do
    get :list, :on => :collection
  end
  resources :organizations do
    get :list, :on => :collection
    get :list_group_natures, :on => :collection
    get :list_group_kinships, :on => :collection
  end
  resources :periods do
    get :list, :on => :collection
  end
  resources :person_contacts do
    get :list, :on => :collection
  end
  resources :person_contact_natures do
    get :list, :on => :collection
    get :list_person_contacts, :on => :collection
  end
  resources :person_honours do
    get :list, :on => :collection
  end
  resources :person_interventions do
    get :list, :on => :collection
  end
  resources :person_intervention_natures do
    get :list, :on => :collection
    get :list_person_interventions, :on => :collection
  end
  resources :products do
    get :list, :on => :collection
    get :list_guests, :on => :collection
    get :list_sale_lines, :on => :collection
    get :list_order_lines, :on => :collection
  end
  resources :promotions do
    get :list, :on => :collection
    get :list_people, :on => :collection
    get :list_questions, :on => :collection
  end
  resources :questions do
    get :list, :on => :collection
    get :list_answers, :on => :collection
    get :list_items, :on => :collection
  end
  resources :question_items do
    get :list, :on => :collection
    get :list_answer_items, :on => :collection
  end
  resources :rubrics do
    get :list, :on => :collection
    get :list_articles, :on => :collection
  end
  resources :sales do
    get :list, :on => :collection
    get :list_guests, :on => :collection
    get :list_lines, :on => :collection
    get :list_passworded_lines, :on => :collection
    get :list_subscriptions, :on => :collection
  end
  resources :sale_lines do
    get :list, :on => :collection
    get :list_guests, :on => :collection
  end
  resources :sectors do
    get :list, :on => :collection
    get :list_activities, :on => :collection
  end
  resources :subscriptions do
    get :list, :on => :collection
  end
  resources :themes do
    get :list, :on => :collection
    get :list_questions, :on => :collection
  end
  resources :zone_natures do
    get :list, :on => :collection
    get :list_children, :on => :collection
    get :list_groups, :on => :collection
  end
  #]ROUTES]
  resources :people do
    collection do
      get :list
    end
  end
  root :to => 'people#index'
end

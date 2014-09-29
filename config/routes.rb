Book::Application.routes.draw do
<<<<<<< HEAD
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
    get :list_mandates, :on => :collection
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
  resources :people do
    get :list, :on => :collection
    get :list_answers, :on => :collection
    get :list_articles, :on => :collection
    get :list_images, :on => :collection
    get :list_members, :on => :collection
    get :list_periods, :on => :collection
    get :list_sales, :on => :collection
    get :list_subscriptions, :on => :collection
    get :list_mandates, :on => :collection
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
=======
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
>>>>>>> 4e9b859b0b36de526142f173a52b123f63570f40
end

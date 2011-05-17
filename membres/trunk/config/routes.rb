# routes membres
ActionController::Routing::Routes.draw do |map|

  map.simple_captcha '/captcha/:action', :controller => 'simple_captcha'

  map.subscribe "inscription", :controller=>"people", :action=>"subscribe"
  map.lost_password "mot-de-passe-perdu", :controller=>"people", :action=>"lost_password"
  map.lost_login "nom-utilisateur-perdu", :controller=>"people", :action=>"lost_login"
  map.activate "activer", :controller=>"people", :action=>"activate"

  map.resource :session, :only=>[:new, :create, :destroy]

  map.resources :languages, :as=>"langues", :except=>[:show]
  map.resources :countries, :as=>"pays", :except=>[:show]
  map.resources :zones, :collection=>{:refresh=>:post}
  map.resources :zone_natures, :as=>"types-de-zone", :except=>[:show]
  map.resources :mandate_natures, :as=>"types-de-mandat", :except=>[:show]
  map.resources :promotions, :only=>[:index, :show], :collection=>{:list=>[:get, :post], :write=>[:get, :post], :people2_dyta=>[:get, :post]}

  map.resources :rubrics, :as=>"rubriques", :collection=>{:rubrics_dyta=>[:get, :post], :rubric_articles_dyta=>[:get, :post]}
  map.resources :articles, :member=>{:activate=>:post, :deactivate=>:post}, :collection=>{:preview=>:get, :help=>:get, :authors_dyli=>[:get, :post], :articles_dyta=>[:get, :post]}
  map.resources :images

  map.resources :mandates, :as=>"mandats", :except=>[:show], :collection=>{:mandates_dyta=>[:get, :post], :people_dyli=>[:get, :post]}
  map.resources :people, :as=>"personnes", :collection=>{:myself=>:get, :update_myself=>[:get, :post], :people_dyta=>[:get, :post], :person_subscriptions_dyta=>[:get, :post], :person_articles_dyta=>[:get, :post], :person_mandates_dyta=>[:get, :post] }, :member=>{:story=>:get, :lock=>:post, :unlock=>:post}


  map.resource :configuration, :only=>[:edit, :update]

  map.resource :myself, :as=>"mon-compte", :only=>[:edit, :update, :show], :collection=>{:change_password=>[:get, :post], :change_email=>[:get, :post], :person_subscriptions_dyta=>[:get, :post], :person_articles_dyta=>[:get, :post], :person_mandates_dyta=>[:get, :post]}

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "myselves", :action=>:show

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end

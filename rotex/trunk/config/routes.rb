ActionController::Routing::Routes.draw do |map|

  map.subscribe "inscription", :controller=>"people", :action=>"subscribe"
  map.lost_password "mot-de-passe-perdu", :controller=>"people", :action=>"lost_password"
  map.lost_login "nom-utilisateur-perdu", :controller=>"people", :action=>"lost_login"
  map.activate "activer", :controller=>"people", :action=>"activate"

  map.special "accueil/:id", :controller=>"home", :action=>"special"

  # Compatibility for old check_payment URL
  map.old_check_payment "/store/check_payment", :controller=>"sales", :action=>"check"

  map.simple_captcha '/captcha/:action', :controller => 'simple_captcha'

  map.resources :languages, :as=>"langues", :except=>[:show]
  map.resources :countries, :as=>"pays", :except=>[:show]
  map.resources :products,  :as=>"produits", :except=>[:show], :collection=>{:check=>:post}
  map.resources :zones, :collection=>{:refresh=>:post}
  map.resources :zone_natures, :as=>"types-de-zone", :except=>[:show]
  map.resources :mandate_natures, :as=>"types-de-mandat", :except=>[:show]
  map.resources :subscriptions, :as=>"adhesions", :except=>[:show], :collection=>{:subscriptions_dyta=>[:get, :post], :chase_up=>[:post], :people_dyli=>[:get, :post]}
  map.resources :promotions, :only=>[:index, :show], :collection=>{:list=>[:get, :post], :write=>[:get, :post], :people2_dyta=>[:get, :post]}


  map.resources :rubrics, :as=>"rubriques", :collection=>{:rubrics_dyta=>[:get, :post], :rubric_articles_dyta=>[:get, :post]}
  map.resources :articles, :member=>{:activate=>:post, :deactivate=>:post}, :collection=>{:preview=>:get, :help=>:get, :authors_dyli=>[:get, :post], :articles_dyta=>[:get, :post]}
  map.resources :images

  map.resources :sales, :as=>"ventes", :member=>{:fill=>[:get, :post], :pay=>[:get, :post], :finish=>:get, :refuse=>:get, :cancel=>:get, :check=>:get}, :collection=>{:sales_dyta=>[:get, :post], :sale_lines_dyta=>[:get, :post]} do |sales|
    sales.resources :lines, :as=>"lignes", :controller=>:sale_lines, :except=>[:show, :index], :member=>{:increment=>:post, :decrement=>:post} do |line|
      line.resources :guests, :as=>"invites", :except=>[:show, :index]
    end
  end

  
  map.resources :mandates, :as=>"mandats", :except=>[:show], :collection=>{:mandates_dyta=>[:get, :post]}
  map.resources :people, :as=>"personnes", :collection=>{:myself=>:get, :update_myself=>[:get, :post], :people_dyta=>[:get, :post], :person_subscriptions_dyta=>[:get, :post], :person_articles_dyta=>[:get, :post], :person_mandates_dyta=>[:get, :post] }, :member=>{:story=>:get, :lock=>:post, :unlock=>:post}

  map.resources :folders, :as=>"dossiers", :only=>[:show, :edit, :update] do |folder|
    folder.resources :members, :as=>"membres", :except=>[:index]
    folder.resources :periods, :as=>"periodes", :except=>[:index], :member=>{:memberize=>[:get, :post], :unmemberize=>[:delete]}
  end

  map.resource :session, :only=>[:new, :create, :destroy]
  map.resource :configuration, :only=>[:edit, :update]
  map.resource :myself, :as=>"mon-compte", :only=>[:edit, :update, :show], :collection=>{:change_password=>[:get, :post], :change_email=>[:get, :post], :person_subscriptions_dyta=>[:get, :post], :person_articles_dyta=>[:get, :post], :person_mandates_dyta=>[:get, :post]}


  
  #map.resource :myself, :as=>"mon-compte" do |myself|
  #  myself.resources :sales, :as=>"ventes" do |sales|
  #    sales.resources :lines, :as=>"lignes", :controller=>:sale_lines, :except=>[:show, :index]
  #  end
  #end  


  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home", :action=>"index"

  # See how all your routes lay out with "rake routes"
end

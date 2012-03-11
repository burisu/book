# routes rotex
ActionController::Routing::Routes.draw do |map|
  map.special "accueil/:id", :controller=>"home", :action=>"special"

  # Compatibility for old check_payment URL
  map.old_check_payment "/store/check_payment", :controller=>"sales", :action=>"check"

  map.simple_captcha '/captcha/:action', :controller => 'simple_captcha'

  map.resources :products,  :as=>"produits", :except=>[:show], :collection=>{:check=>:post}
  map.resources :subscriptions, :as=>"adhesions", :except=>[:show], :collection=>{:subscriptions_dyta=>[:get, :post], :chase_up=>[:post], :people_dyli=>[:get, :post]}

  map.resources :rubrics, :as=>"rubriques", :collection=>{:rubrics_dyta=>[:get, :post], :rubric_articles_dyta=>[:get, :post]}
  map.resources :articles, :member=>{:activate=>:post, :deactivate=>:post}, :collection=>{:preview=>:get, :help=>:get, :authors_dyli=>[:get, :post], :articles_dyta=>[:get, :post]}
  map.resources :images

  map.resources :sales, :as=>"ventes", :member=>{:fill=>[:get, :post], :pay=>[:get, :post], :finish=>:get, :refuse=>:get, :cancel=>:get, :check=>:get}, :collection=>{:sales_dyta=>[:get, :post], :sale_lines_dyta=>[:get, :post]} do |sales|
    sales.resources :lines, :as=>"lignes", :controller=>:sale_lines, :except=>[:show, :index], :member=>{:increment=>:post, :decrement=>:post} do |line|
      line.resources :guests, :as=>"invites", :except=>[:show, :index]
    end
  end
  
  map.resources :people, :as=>"personnes", :only=>[:show], :member=>{:story=>:get}, :collection=>{:person_subscriptions_dyta=>[:get, :post], :person_articles_dyta=>[:get, :post], :person_mandates_dyta=>[:get, :post] }

  map.resource :session, :only=>[:new, :create, :destroy]
  map.resource :myself, :as=>"mon-compte", :only=>[:edit, :update, :show], :collection=>{:change_password=>[:get, :post], :change_email=>[:get, :post], :person_subscriptions_dyta=>[:get, :post], :person_articles_dyta=>[:get, :post], :person_mandates_dyta=>[:get, :post], :lost_login=>[:get, :post], :lost_password=>[:get, :post]}

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home", :action=>"index"

  # See how all your routes lay out with "rake routes"
end

ActionController::Routing::Routes.draw do |map|

  map.simple_captcha '/captcha/:action', :controller => 'simple_captcha'

  map.resources :languages, :as=>"langues", :except=>[:show]
  map.resources :countries, :as=>"pays", :except=>[:show]
  map.resources :products,  :as=>"produits", :except=>[:show]
  map.resources :zones, :collection=>{:refresh=>:post}
  map.resources :subscriptions, :as=>"adhesions", :except=>[:show], :collection=>{:list=>[:get, :post], :chase_up=>[:post]}


  map.resources :rubrics, :as=>"rubriques"

  map.resources :sales, :as=>"ventes", :member=>{:fill=>[:get, :post], :pay=>[:get, :post]} do |sales|
    sales.resources :lines, :as=>"lignes", :controller=>:sale_lines, :except=>[:show, :index], :member=>{:increment=>:post, :decrement=>:post} do |line|
      line.resources :guests, :as=>"invites", :except=>[:show, :index]
    end
  end

  
  map.resources :mandates, :as=>"mandats", :except=>[:show]
  map.resources :people, :as=>"personnes"

  
  #map.resource :myself, :as=>"mon-compte" do |myself|
  #  myself.resources :sales, :as=>"ventes" do |sales|
  #    sales.resources :lines, :as=>"lignes", :controller=>:sale_lines, :except=>[:show, :index]
  #  end
  #end  

  map.login 'connexion', :controller=>"authentication", :action=>"index"

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

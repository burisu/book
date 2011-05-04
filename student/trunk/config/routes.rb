ActionController::Routing::Routes.draw do |map|
  
  
  
  map.resources :questionnaires, :member=>{:wake_up_absents=>:post, :duplicate=>:post}
  map.resources :answers, :only=>[:index, :destroy], :member=>{:lock=>:post, :unlock=>:post, :accept=>:post, :reject=>:post}, :collection=>{:fill=>[:get, :post]}

  map.resources :themes, :except=>[:show]
  map.simple_captcha '/captcha/:action', :controller => 'simple_captcha'

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "suivi"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

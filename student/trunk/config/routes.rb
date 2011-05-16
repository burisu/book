ActionController::Routing::Routes.draw do |map|
  map.simple_captcha '/captcha/:action', :controller => 'simple_captcha'

  map.resource :session, :only=>[:new, :create, :destroy]

  map.resources :questionnaires, :member=>{:wake_up_absents=>:post, :duplicate=>:post}, :collection=>{:questionnaires_dyta=>[:get, :post], :questionnaire_answers_dyta=>[:get, :post], :questionnaire_questions_dyta=>[:get, :post], :questionnaire_students_dyta=>[:get, :post]}
  map.resources :questions, :except=>[:index, :show], :member=>{:up=>:post, :down=>:post}
  map.resources :answers, :as=>"reponses", :only=>[:index, :destroy], :member=>{:lock=>:post, :unlock=>:post, :accept=>:post, :reject=>:post}, :collection=>{:fill=>[:get, :post]}
  map.resources :themes, :except=>[:show], :collection=>{:themes_dyta=>[:get, :post]}

  map.resource :myself, :as=>"mon-compte", :only=>[:show], :member=>{:lost_login=>[:get, :post], :lost_password=>[:get, :post]}

  map.root :controller => "myselves", :action=>"show"

  # Install the default routes as the lowest priority.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end

# Routes Student Exchange
ActionController::Routing::Routes.draw do |map|
  map.simple_captcha '/captcha/:action', :controller => 'simple_captcha'

  map.resource :session, :only=>[:new, :create, :destroy]

  map.resources :rubrics, :as=>"rubriques", :collection=>{:rubrics_dyta=>[:get, :post], :rubric_articles_dyta=>[:get, :post]}
  map.resources :articles, :member=>{:activate=>:post, :deactivate=>:post}, :collection=>{:preview=>:get, :help=>:get, :authors_dyli=>[:get, :post], :articles_dyta=>[:get, :post]}
  map.resources :images

  map.resources :folders, :as=>"dossiers", :only=>[:show, :edit, :update] do |folder|
    folder.resources :members, :as=>"membres", :except=>[:index]
    folder.resources :periods, :as=>"periodes", :except=>[:index], :member=>{:memberize=>[:get, :post], :unmemberize=>[:delete]}
  end

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

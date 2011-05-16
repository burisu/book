# -*- coding: utf-8 -*-
class QuestionnairesController < ApplicationController

  dyta(:questionnaires, :order=>"started_on DESC, name") do |t|
    t.column :name, :url=>{:action=>:show}
    t.column :started_on
    t.column :stopped_on
    t.column :name, :through=>:promotion
    t.column :active, :datatype=>:boolean
    t.column :questions_size
    t.column :answers_size, :url=>{:controller=>:answers, :questionnaire_id=>"RECORD.id"}
    t.action :edit
    t.action :duplicate, :image=>:spread
    t.action :destroy, :method=>:delete, :confirm=>"Are you sure\?"
  end

  def index
    @questionnaires = Questionnaire.find(:all, :order=>"started_on DESC, name")
  end

  dyta(:questionnaire_questions, :model=>:questions, :conditions=>{:questionnaire_id=>['session[:current_questionnaire]']}, :order=>'position') do |t|
    t.column :position
    t.column :name, :through=>:theme
    t.column :name
    t.column :explanation
    t.action :up, :url=>{:controller=>:questions, :action=>:up}, :if=>"!RECORD.first\? and !RECORD.questionnaire.active", :remote=>true, :update=>:questionnaire_questions
    t.action :down, :url=>{:controller=>:questions, :action=>:down}, :if=>"!RECORD.last\? and !RECORD.questionnaire.active", :remote=>true, :update=>:questionnaire_questions
    t.action :edit, :url=>{:controller=>:questions, :action=>:edit}, :if=>"!RECORD.questionnaire.active"
    t.action :destroy, :url=>{:controller=>:questions, :action=>:destroy}, :method=>:delete, :confirm=>"Are you sure\?", :remote=>true, :update=>:questionnaire_questions, :if=>"!RECORD.questionnaire.active"
  end
  

  dyta(:questionnaire_answers, :model=>:answers, :joins=>"JOIN people ON (people.id=person_id)", :conditions=>["questionnaire_id=\?", ['session[:current_questionnaire]']], :per_page=>50, :order=>"family_name, first_name") do |t|
    t.column :label, :through=>:person
    t.column :status
    t.action :index, :url=>{:controller=>:answers, :anchor=>"'answer'+RECORD.id.to_s", :questionnaire_id=>"session[:current_questionnaire]"}, :image=>:search
    t.action :destroy, :url=>{:controller=>:answers}, :method=>:delete
  end


  dyta(:questionnaire_students, :model=>:people, :conditions=>["student AND promotion_id=? AND id NOT IN (SELECT person_id FROM answers WHERE questionnaire_id=?)", ['session[:current_questionnaire_promotion_id]'], ['session[:current_questionnaire]']], :per_page=>50, :order=>"family_name") do |t|
    t.column :family_name
    t.column :first_name
    t.column :email
  end

  def show
    @questionnaire = Questionnaire.find_by_id(params[:id])
    @questions = @questionnaire.questions
    session[:current_questionnaire] = @questionnaire ? @questionnaire.id : 0
    session[:current_questionnaire_promotion_id] = @questionnaire ? @questionnaire.promotion_id : 0
  end


  def new
    @questionnaire = Questionnaire.new(:name=>'Nouveau questionnaire')
    render_form
  end

  def create
    @questionnaire = Questionnaire.new(params[:questionnaire])
    if @questionnaire.save
      redirect_to questionnaire_url(@questionnaire)
    end
    render_form
  end

  def edit
    @questionnaire = Questionnaire.find_by_id(params[:id])
    render_form
  end
  
  def update
    @questionnaire = Questionnaire.find_by_id(params[:id])
    if @questionnaire.update_attributes(params[:questionnaire])
      redirect_to questionnaire_url(@questionnaire)
    end
    render_form
  end

  def destroy
    @questionnaire = Questionnaire.find_by_id(params[:id])
    if @questionnaire.id and @questionnaire.answers_size<=0
      @questionnaire.destroy
      flash[:notice] = 'Suppression de '+@questionnaire.name+' effectuée'
    end
    redirect_to questionnaires_url
  end

  def wake_up_absents
    questionnaire = Questionnaire.find_by_id(params[:id])
    people = Person.find(:all, :conditions=>["student AND promotion_id = ? AND id NOT IN (SELECT person_id FROM answers WHERE questionnaire_id=?)", session[:current_questionnaire_promotion_id], session[:current_questionnaire]])
    Maily.deliver_awakenings(people, questionnaire, @current_person)
    redirect_to questionnaire_url(questionnaire)
  end

  def duplicate
    questionnaire = Questionnaire.find_by_id(params[:id])
    if questionnaire
      redirect_to questionnaire_url(questionnaire.duplicate)
      return
    end
    redirect_to questionnaires_url
  end

end

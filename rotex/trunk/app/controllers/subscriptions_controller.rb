# -*- coding: utf-8 -*-
class SubscriptionsController < ApplicationController

  dyli(:people, [:first_name, :family_name, :user_name, :address], :model=>:people)


  dyta(:subscriptions, :order=>"created_at DESC" ) do |t|
    t.column :number, :class=>:code, :url=>{:action=>:edit}
    # t.column :family_name, :through=>:person, :url=>{:action=>:person}
    # t.column :first_name, :through=>:person, :url=>{:action=>:person}
    t.column :label, :through=>:person, :url=>{:controller=>:people, :action=>:show}
    t.column :number, :through=>:sale, :url=>{:action=>:show, :controller=>:sales}
    t.column :begun_on
    t.column :finished_on
    t.action :destroy, :method=>:delete, :confirm=>:are_you_sure
  end

  def index
  end

  def new
    @subscription = Subscription.new
    @title = "Nouvelle adhésion"
    render_form
  end

  def create
    @subscription = Subscription.new(params[:subscription])
    if @subscription.save
      redirect_to subscriptions_url
    end
    @title = "Nouvelle adhésion"
    render_form
  end

  def edit
    @subscription = Subscription.find(params[:id])
    @title = "Modifier la adhésion #{@subscription.number}"
    render_form
  end

  def update
    @subscription = Subscription.find(params[:id])
    @title = "Modifier la adhésion #{@subscription.number}"
    if @subscription.update_attributes(params[:subscription])
      redirect_to subscriptions_url
    end
    render_form
  end

  def destroy
    Subscription.find(params[:id]).destroy
    redirect_to subscriptions_url
  end

  def chase_up
    @people = Subscription.chase_up
    render :index
  end


  # def subscriptions
  #   # >> :subscribing
  #   if request.post?
  #     Subscription.delete_all(["state=? AND created_at<=? ", "I", Time.now - 48.hours])
  #   elsif request.put?
  #     @people = Subscription.chase_up
  #   end
  # end


  # def subscription_create
  #   # >> :subscribing
  #   @person = Person.find(params[:id])
  #   if request.post?
  #     @subscription = Subscription.new(params[:subscription])
  #     @subscription.person_id = @person.id
  #     @subscription.responsible = @current_person
  #     if @subscription.save
  #       @subscription.person.approve!
  #       session[:last_finished_on] = @subscription.finished_on
  #       redirect_to :action=>:person, :id=>@person.id
  #     end
  #   else
  #     @subscription = Subscription.new
  #     @subscription.finished_on = session[:last_finished_on] if session[:last_finished_on]
  #   end
  #   @title = "Enregistrement d'une cotisation"
  #   render_form
  # end

  # def subscription_update
  #   # >> :subscribing
  #   @subscription = Subscription.find(params[:id])
  #   if request.post?
  #     @subscription.attributes = params[:subscription]
  #     @subscription.responsible = @current_person
  #     if @subscription.save
  #       redirect_to :action=>:subscriptions
  #     end
  #   end
  #   @title = "Modification de la cotisation #{@subscription.number}"
  #   render_form
  # end

  # def subscription_delete
  #   # >> :subscribing
  #   s = Subscription.find(params[:id])
  #   s.destroy if request.post? or request.delete?
  #   redirect_to :action=>:person, :id=>s.person_id
  # end



end

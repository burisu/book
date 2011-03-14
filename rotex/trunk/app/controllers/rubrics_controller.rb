# -*- coding: utf-8 -*-
class RubricsController < ApplicationController

  dyta(:rubrics) do |t|
    t.column :name, :url=>{:action=>:show}
    t.column :description
    t.column :name, :through=>:parent
    t.action :edit
    t.action :destroy, :method=>:delete, :confirm=>:are_you_sure
  end

  def self.rubric_articles_conditions    
    {:rubric_id=>['session[:current_rubric_id]']}
  end

  dyta(:rubric_articles, :model=>:articles, :conditions=>["rubric_id=? AND status = 'P' AND (amn.article_id IS NULL OR (amn.article_id IS NOT NULL AND m.person_id=? AND CURRENT_DATE BETWEEN COALESCE(m.begun_on, CURRENT_DATE) AND COALESCE(m.finished_on, CURRENT_DATE)))", ['session[:current_rubric_id]'], ['session[:current_person_id]']],  :joins=>"JOIN people ON (people.id=author_id) LEFT JOIN articles_mandate_natures AS amn ON (amn.article_id=articles.id) LEFT JOIN mandates AS m ON (m.nature_id=amn.mandate_nature_id)", :order=>"people.family_name, people.first_name, created_at DESC", :per_page=>20) do |t|
    t.column :title, :url=>{:controller=>:articles, :action=>:show}
    t.column :label, :through=>:author, :url=>{:controller=>:people, :action=>:show}
    t.column :updated_at
    t.column :created_at
  end

  def index
  end

  def show
    @rubric = Rubric.find_by_code(params[:id])
    session[:current_rubric_id] = @rubric.id
  end

  def new
    @rubric = Rubric.new
    @title = "Nouvelle rubrique"
    render_form
  end

  def create
    @rubric = Rubric.new(params[:rubric])
    if @rubric.save
      redirect_to rubrics_url
    end
    @title = "Nouvelle rubrique"
    render_form
  end

  def edit
    @rubric = Rubric.find_by_code(params[:id])
    @title = "Modifier la rubrique #{@rubric.name}"
    render_form
  end

  def update
    @rubric = Rubric.find_by_code(params[:id])
    @title = "Modifier la rubrique #{@rubric.name}"
    if @rubric.update_attributes(params[:rubric])
      redirect_to rubrics_url
    end
    render_form
  end

  def destroy
    Rubric.find_by_code(params[:id]).destroy
    redirect_to rubrics_url
  end

end

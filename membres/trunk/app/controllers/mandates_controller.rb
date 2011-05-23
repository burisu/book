class MandatesController < ApplicationController

  dyli(:people, [:first_name, :family_name, :user_name, :address], :model=>:people)

  dyta(:mandates, :joins=>"JOIN mandate_natures mn ON (mn.id=nature_id) JOIN people p ON (person_id=p.id)", :order=>"(dont_expire OR CURRENT_DATE BETWEEN begun_on AND COALESCE(finished_on, CURRENT_DATE)) DESC, mn.name, p.family_name, p.first_name", :line_class=>"(RECORD.active? ? 'notice' : '')") do |t|
    t.column :name, :through=>:nature, :label=>"Mandat"
    t.column :label, :through=>:person, :url=>{:controller=>:people, :action=>:show}, :label=>"Personne"
    t.column :begun_on
    t.column :finished_on
    t.column :name, :through=>:zone, :url=>{:controller=>:zones, :action=>:show}
    t.action :edit
    t.action :destroy, :method=>:delete, :confirm=>:are_you_sure
  end

  def index
  end

  def new
    @mandate = Mandate.new :person_id=>params[:person_id], :begun_on=>Date.today
    render_form
  end

  def create
    @mandate = Mandate.new :person_id=>params[:id]

    if request.post?
      @mandate.attributes = params[:mandate]
      if @mandate.save
        redirect_to mandates_url
      end
    end
    render_form
  end

  def edit
    @mandate = Mandate.find params[:id]
    render_form
  end

  def update
    @mandate = Mandate.find params[:id]
    @mandate.attributes = params[:mandate]
    redirect_to mandates_url if @mandate.save
  end

  def destroy
    Mandate.find(params[:id]).destroy
    redirect_to mandates_url
  end

end

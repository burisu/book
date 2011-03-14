# -*- coding: utf-8 -*-
class PeopleController < ApplicationController

  def self.people_conditions
    code = search_conditions(:people, [:family_name, :first_name, :patronymic_name, :email, :comment, :address, :second_name, :user_name])
    code += "\n"
    code += "if session[:person_mode]=='not_approved'\n"
    code += "  c[0]+=' AND NOT approved'\n"
    code += "elsif session[:person_mode]=='student'\n"
    code += "  c[0]+=' AND student'\n"
    code += "elsif session[:person_mode]=='not_student'\n"
    code += "  c[0]+=' AND NOT student'\n"
    code += "elsif session[:person_mode]=='locked'\n"
    code += "  c[0]+=' AND is_locked'\n"
    code += "end\n"
    code += "if session[:person_state]=='valid'\n"
    code += "  c[0]+=\" AND id IN (SELECT person_id FROM subscriptions WHERE state='P' AND CURRENT_DATE BETWEEN begun_on AND finished_on)\"\n"
    code += "elsif session[:person_state]=='not'\n"
    code += "  c[0]+=\" AND NOT id IN (SELECT person_id FROM subscriptions WHERE state='P' AND CURRENT_DATE BETWEEN begun_on AND finished_on)\"\n"
    code += "elsif session[:person_state]=='end'\n"
    code += "  conf = Configuration.the_one\n"
    code += "  c[0]+=\" AND id IN (SELECT person_id FROM subscriptions WHERE state='P' AND CURRENT_DATE - finished_on BETWEEN \#\{conf.first_chasing_up\} AND \#\{conf.last_chasing_up\}) AND NOT id IN (SELECT person_id FROM subscriptions WHERE state='P' AND finished_on > CURRENT_DATE + '\#\{conf.last_chasing_up\} days'::INTERVAL)\"\n"
    code += "end\n"
    code += "if session[:person_proposer_zone_id] > 0\n"
    code += "  c[0]+=' AND proposer_zone_id=?'\n"
    code += "  c << session[:person_proposer_zone_id]\n"
    code += "end\n"
    code += "if session[:person_arrival_country_id] > 0\n"
    code += "  c[0]+=' AND arrival_country_id=?'\n"
    code += "  c << session[:person_arrival_country_id]\n"
    code += "end\n"
    code += "c"
    return code
  end


  dyta(:people, :conditions=>people_conditions, :order=>"family_name, first_name", :per_page=>20, :line_class=>"(RECORD.is_locked ? 'error' : (RECORD.has_subscribed? ? 'notice' : (RECORD.has_subscribed_on? ? 'warning' : '')))") do |t|
    t.column :family_name, :url=>{:action=>:show}
    t.column :first_name, :url=>{:action=>:show}
    t.column :user_name
    t.column :address
    t.column :student
    t.action :is_locked, :actions=>{"true"=>{:action=>:unlock}, "false"=>{:action=>:lock}}
    t.action :edit
    t.action :destroy, :method=>:delete, :confirm=>:are_you_sure
  end


  def index
    @title = "Liste des personnes"
    session[:person_key] = params[:person_key]||params[:key]
    session[:person_mode] = params[:mode]
    session[:person_state] = params[:state]
    session[:person_proposer_zone_id] = params[:proposer_zone_id].to_i
    session[:person_arrival_country_id] = params[:arrival_country_id].to_i
    # @people = Person.paginate(:all, :order=>"family_name, first_name", :page=>params[:page], :per_page=>50)
  end

  dyta(:person_articles, :model=>:articles, :conditions=>{:author_id=>['session[:person_id]']}, :order=>"created_at DESC", :per_page=>10, :line_class=>"(RECORD.status.to_s == 'R' ? 'warning' : (Time.now-RECORD.updated_at <= 3600*24*30 ? 'notice' : ''))", :export=>false) do |t|
    t.column :title, :url=>{:controller=>:articles, :action=>:show}
    t.column :name, :through=>:rubric, :url=>{:controller=>:rubrics, :action=>:show}
    t.column :updated_at
    t.action :edit, :controller=>:articles, :if=>"not RECORD.locked\?"
    t.action :destroy, :controller=>:articles, :method=>:delete,  :confirm=>"Sûr(e)\?"
  end

  dyta(:person_mandates, :model=>:mandates, :conditions=>{:person_id=>['session[:person_id]']}, :order=>"begun_on DESC", :export=>false, :per_page=>5) do |t|
    t.column :name, :through=>:nature
    t.column :begun_on
    t.column :finished_on
  end

  dyta(:person_subscriptions, :model=>:subscriptions, :conditions=>{:person_id=>['session[:person_id]']}, :order=>"begun_on DESC", :export=>false, :per_page=>5) do |t|
    t.column :number, :class=>"code"
    t.column :begun_on
    t.column :finished_on
    # t.column :payment_mode_label
    # t.column :state_label
  end





  def show
    @person = Person.find_by_id(params[:id])
    session[:person_id] = @person.id    
    redirect_to people_url if @person.nil?
    @subscriptions = @person.subscriptions
    @mandates = @person.mandates
    @articles = @person.articles
  end
  
  def new
    @person = Person.new
    render_form
  end
  
  def create
    @person = Person.new params[:person]
    @person.email = params[:person][:email]
    @person.email = Digest::MD5.hexdigest(@person.label)+'@'+rand.to_s if @person.email.blank?
    @person.user_name = @person.patronymic_name.downcase.gsub(/[^a-z0-9\_\.]/,'') if @person.user_name.blank?
    @person.is_validated = true
    @person.is_locked = false
    @person.is_user   = true
    password = Person.generate_password
    @person.password = password
    @person.password_confirmation = password
    if @person.save
      begin
        Maily.deliver_password(@person, password) if RAILS_ENV != 'development'
      rescue
        flash[:warning] = "L'e-mail de confirmation n'a pas pu être envoyé."
      end
      flash[:notice] = 'La personne '+@person.label+' a été créée'
      redirect_to people_url
    end
    render_form
  end
  
  def edit
    @person = Person.find(params[:id])
    render_form
  end
  
  def update
    @person = Person.find(params[:id])
    unless access? :all 
      params[:person][:password] = ''
      params[:person][:password_confirmation] = ''
    end
    @person.attributes = params[:person]
    @person.forced = true
    @person.email = params[:person][:email]
    if @person.save
      flash[:notice] = 'La personne '+@person.label+' a été modifiée'
      redirect_to people_url
    end
    render_form
  end
  

  def myself
    @person = Person.find(session[:current_person_id])
    session[:person_id] = @person.id
    if params[:mode] == "card"
      send_file visit_card(@person), :filename=>"#{@person.label}.pdf", :type=>"application/pdf"
    end
  end

  def update_myself
    @person = Person.find(session[:current_person_id])
    if request.post?
      params2 = {}
      if @current_person.admin?
        params2 = params[:person]||{}
      else
        [:address, :phone, :phone2, :fax, :mobile, :photo].each {|x| params2[x] = params[:person][x] if params[:person].has_key? x}
      end
      @person.attributes = params2
      @person.forced = true
      if @person.save
        redirect_to :action=>:profile
      end
    end
  end

  
  def lock
    # >> :users
    p = Person.find(params[:id])
    p.is_locked = true
    p.forced    = true
    p.save!
    redirect_to people_url
  end
  
  def unlock
    # >> :users
    p = Person.find(params[:id])
    p.is_locked = false
    p.forced    = true
    p.save!
    redirect_to people_url
  end
  
  def destroy
    begin
      Person.find(params[:id]).destroy 
    rescue
      flash[:warning] = "La personne n'a pas pu être supprimée"
    end
    redirect_to people_url
  end 

  include Prawn::Measurements

  hide_action :visit_card
  def visit_card(people)
    people = [people] unless people.is_a? Array
    lines = 5
    columns = 2
    width = mm2pt(85)
    height = mm2pt(54)
    page = [mm2pt(210), mm2pt(297)]
    wmargin = (page[0]-columns*width)/2 # mm2pt(10)
    hmargin = (page[1]-lines*height)/2
    intm = 0.1
    first = true
    file = File.join(RAILS_ROOT, "tmp", "vcard#{rand}.pdf")
    Prawn::Document.generate(file, :page_size=>page, :margin=>[hmargin, wmargin]) do |pdf|
      for person in people
        pdf.start_new_page unless first
        first = false
        lines.times do |l|
          columns.times do |c|
            # Bord de découpe
            pdf.stroke do
              pdf.line_width(0.1)
              pdf.line([c*width, -intm*hmargin], [c*width, -hmargin])
              pdf.line([(c+1)*width, -intm*hmargin], [(c+1)*width, -hmargin])
              pdf.line([c*width, page[1]+(intm-2)*hmargin], [c*width, page[1]])
              pdf.line([(c+1)*width, page[1]+(intm-2)*hmargin], [(c+1)*width, page[1]])
              pdf.line([-wmargin, l*height], [-intm*wmargin, l*height])
              pdf.line([-wmargin, (l+1)*height], [-intm*wmargin, (l+1)*height])
              pdf.line([page[0]+(intm-2)*wmargin, l*height], [page[0], l*height])
              pdf.line([page[0]+(intm-2)*wmargin, (l+1)*height], [page[0], (l+1)*height])
            end

            pdf.bounding_box([c*width, (l+1)*height], :width=>width, :height=>height) do
              pdf.image((person.photo("portrait") ? person.photo("portrait") : File.join(RAILS_ROOT, "public", "images", "nobody.png")), :at=>[5, height-5], :fit=>[0.4*width-10, 0.8*height]) 
              # pdf.image(File.join(RAILS_ROOT, "public", "images", "rotex.png"), :at=>[(width-0.8*height)/2, 0.9*height], :height=>0.8*height) # , :width=>width, :height=>height)
              pdf.image(File.join(RAILS_ROOT, "public", "images", "rotex.png"), :at=>[0.4*width+5, 0.9*height], :height=>0.8*height) # , :width=>width, :height=>height)
              if country = person.arrival_country
                pdf.image(File.join(RAILS_ROOT, "public", "images", "country", country.iso3166.lower+".png"), :at=>[0.4*width, height-5]) # , :width=>width, :height=>height)
                pdf.text_box(country.name, :at=>[0.4*width+20, height-7], :overflow=>:shrink_to_fit, :size=>10)
              end
              # :at=>[0.4*width, 0.5*height],
              pdf.bounding_box([0.4*width, 78], :width=>0.6*width-5) do
                pdf.text_box person.first_name, :size=>14, :style=>:bold, :align=>:center, :overflow=>:shrink_to_fit, :at=>[0, 32]
                pdf.text_box person.patronymic_name, :size=>14, :style=>:bold, :align=>:center, :overflow=>:shrink_to_fit, :at=>[0, 16]
              end
              pdf.bounding_box([0.4*width, 25], :width=>width-10) do
                pdf.text_box(person.mobile, :at=>[0, 33], :size=>8, :overflow=>:shrink_to_fit)
                pdf.text_box(person.sponsor_zone.name, :at=>[0, 22], :size=>8, :overflow=>:shrink_to_fit) if person.sponsor_zone
                pdf.text_box(person.host_zone.name, :at=>[0, 11], :size=>8, :overflow=>:shrink_to_fit) if person.host_zone
              end
              pdf.bounding_box([5, 5], :width=>width-10) do
                pdf.text_box(person.rotex_email, :at=>[0, 17], :size=>8, :overflow=>:shrink_to_fit, :align=>:center)
                pdf.text_box(person.address.gsub(/\n/, ', '), :at=>[0, 7], :size=>8, :overflow=>:shrink_to_fit, :align=>:center)
              end
            end
          end
        end
      end
    end
    return file
  end


  def approve
    @person = Person.find_by_id(params[:id])
    if @person and @person.hashed_salt==params[:xid]
      @person.approve!
      flash[:notice] = "La personne a été acceptée."
    else
      flash[:error] = "Vous n'avez pas le droit de faire cela."
    end
    redirect_to :action=>:index
  end

  def disapprove
    @person = Person.find_by_id(params[:id])
    if @person and @person.hashed_salt==params[:xid]
      @person.disapprove!
      flash[:notice] = "La personne a été verrouillée."
    else
      flash[:error] = "Vous n'avez pas le droit de faire cela."
    end
    redirect_to :action=>:index
  end


  def story
    person_id = session[:current_person_id]
    person_id = params[:id] if params[:id] # and access?
    @author = Person.find_by_id(person_id)
    @reports = @author.reports
    expire_fragment(:controller=>:intra, :action=>:story, :id=>@author.id)
  end



end

class IntraController < ApplicationController

  before_filter :authorize
  cattr_reader :images_count_per_person
  @@images_count_per_person = 100


  def index
    profile
    render :action=>:profile
  end
  
  def configurate
    @configuration = @@configuration
    if request.post?
      @configuration.attributes = params[:configuration]
      @configuration.save
    end
  end

  dyta(:person_articles, :model=>:articles, :conditions=>{:author_id=>['session[:current_person_id]']}, :order=>"created_at DESC", :per_page=>10, :line_class=>"(RECORD.status.to_s == 'R' ? 'warning' : (Time.now-RECORD.updated_at <= 3600*24*30 ? 'notice' : ''))", :export=>false) do |t|
    t.column :title, :url=>{:action=>:article}
    t.column :name, :through=>:rubric, :url=>{:action=>:rubric}
    t.column :updated_at
    # t.action :status, :actions=>{"P"=>{:action=>:article_deactivate}, "R"=>{:action=>:article_activate}, "U"=>{:action=>:article_activate}, "W"=>{:action=>:article_update}, "C"=>{:action=>:article_update}}
    t.action :article_update, :if=>"not RECORD.locked\?"
    t.action :article_delete, :method=>:post,  :confirm=>"Sûr(e)\?"
  end

  dyta(:person_mandates, :model=>:mandates, :conditions=>{:person_id=>['session[:current_person_id]']}, :order=>"begun_on DESC", :export=>false) do |t|
    t.column :name, :through=>:nature
    t.column :begun_on
    t.column :finished_on
  end

  def profile
    @person = Person.find(session[:current_person_id])
  end

  def profile_update
    @person = Person.find(session[:current_person_id])
    if request.post?
      params2 = {}
      [:address, :phone, :phone2, :fax, :mobile].each {|x| params2[x] = params[:person][x]}
      @person.attributes = params2
      @person.forced = true
      if @person.save
        redirect_to :action=>:profile
      end
    end
  end


  dyta(:folders, :model=>:people, :order=>"family_name, first_name", :conditions=>['promotion_id IS NOT NULL'], :line_class=>"(RECORD.current? ? 'notice' : '')", :order=>"started_on DESC") do |t|
    t.action :folder, :image=>:show
    t.column :family_name, :url=>{:action=>:person}
    t.column :first_name, :url=>{:action=>:person}
    t.column :name, :through=>:promotion
    t.column :started_on
    t.column :stopped_on
    t.column :name, :through=>:proposer_zone
    t.column :name, :through=>:departure_country
    t.column :name, :through=>:arrival_country
    t.action :folder_delete, :method=>:delete, :confirm=>:are_you_sure, :if=>'!RECORD.student'
  end


  def folders
  end


  def folder
    if params[:id].blank? or (not access?(:folders) and params[:id] != session[:current_person_id].to_s)
      flash[:error] = "Vous n'avez pas accès à ce dossier"
      redirect_to :back
      return
    end
    @person = Person.find_by_id(params[:id]) # session[:current_person_id]

#     person_id = session[:current_person_id]
#     if access?(:folders) and params[:id]
#       @person = Person.find_by_id(params[:id])
#     elsif access?(:folders) and params[:person_id]
#       person_id = params[:person_id].to_i 
#     end
#     @person = Person.find(:first, :conditions=>{:person_id=>person_id}) unless @person
#     unless @person 
#       redirect_to :action=>:folder_update 
#       return
#     end
    session[:current_folder_id] = @person.id
    @reports = []
    @periods = []
    @reports2 = {}
    session[:periods] ||= {}
    @owner_mode = (session[:current_person_id]==@person.id ? true : false)
    
    if @person
#       start = @person.begun_on.at_beginning_of_month
#       stop = (Date.today<@person.finished_on ? Date.today : @person.finished_on)
#       while start <= stop do
#         article = Article.find(:first, :conditions=>{:done_on=>start, :author_id=>@person.id})
#         @reports << {:name=>start.year.to_s+'/'+start.month.to_s.rjust(2,'0'), :title=>(article.nil? ? "Créer" : article.title), :month=>start.year.to_s+start.month.to_s, :class=>(article.nil? ? "create" : nil)}
#         @reports2[start.year.to_s] ||= []
#         @reports2[start.year.to_s] << {:month=>I18n.translate('date.month_names')[start.month], 
#           :name=>start.year.to_s+'/'+start.month.to_s.rjust(2,'0'), 
#           :title=>(article.nil? ? "Créer" : article.title), 
#           :id=>(article ? article.id : 0), 
#           :month_id=>start.year.to_s+start.month.to_s, 
#           :class=>(article.nil? ? "create" : nil)}
#         start = start >> 1
#         break if @reports.size>=24
#       end
      @reports = @person.reports
      @periods = @person.periods.find(:all, :order=>:begun_on)
    end
    # raise Exception.new @person.inspect
  end


  def folder_create
    unless @current_person.student
      flash[:error] = "Vous n'avez pas accès à ce dossier"
      redirect_to :back
      return
    end
    @person = @current_person
    @person.attributes = params[:person]
    @zone_nature = ZoneNature.find(:first, :conditions=>["LOWER(name) LIKE 'club'"])
    @zones = Zone.find(:all, :select=>"co.name||' - '||district.name||' - '||zones.name AS long_name, zones.id AS zid", :joins=>" join zones as zse on (zones.parent_id=zse.id) join zones as district on (zse.parent_id=district.id) join countries AS co ON (zones.country_id=co.id)", :conditions=>["zones.nature_id=?",@zone_nature.id], :order=>"co.iso3166, district.name, zones.name").collect {|p| [ p[:long_name], p[:zid].to_i ] }||[]
    if @zones.empty?    
      flash[:warning] = 'Vous ne pouvez pas modifier votre voyage actuellement. Réessayez plus tard.'
      redirect_to :action=>:profile 
      return
    end
    if request.post?
      @person.forced = true
      if @person.save
        redirect_to :action=>:folder, :id=>@person.id
        return
      end        
    end
    @title = "Enregistrement du voyage"
    render_form
  end



  def folder_update
    if params[:id].blank? or (not access?(:folders) and params[:id] != session[:current_person_id].to_s)
      flash[:error] = "Vous n'avez pas accès à ce dossier"
      redirect_to :back
      return
    end
    @person = Person.find(:first, :conditions=>{:id=>params[:id]}) # session[:current_person_id]
    @zone_nature = ZoneNature.find(:first, :conditions=>["LOWER(name) LIKE 'club'"])
    @zones = Zone.find(:all, :select=>"co.name||' - '||district.name||' - '||zones.name AS long_name, zones.id AS zid", :joins=>" join zones as zse on (zones.parent_id=zse.id) join zones as district on (zse.parent_id=district.id) join countries AS co ON (zones.country_id=co.id)", :conditions=>["zones.nature_id=?",@zone_nature.id], :order=>"co.iso3166, district.name, zones.name").collect {|p| [ p[:long_name], p[:zid].to_i ] }||[]
    if @zones.empty?    
      flash[:warning] = 'Vous ne pouvez pas modifier votre voyage actuellement. Réessayez plus tard.'
      redirect_to :action=>:profile 
      return
    end
    if request.post?
      @person.attributes = params[:person]
      @person.forced = true
      if @person.save
        redirect_to :action=>:folder, :id=>@person.id
      end        
    else
      @person ||= Person.new
    end
  end




  def folder_delete
    if request.post? or request.delete?
      @person = Person.find_by_id(params[:id])
      @person.update_attribute(:promotion_id, nil) unless @person.nil?
      redirect_to :action=>:folders
    end
  end


  def report
    session[:no_history] = true
    begin
      year = params[:id].to_s[0..3].to_i
      month = params[:id].to_s[4..-1].to_i
    rescue
      flash[:error] = "Code d'article invalide"
      redirect_to :back
      return
    end
    start = Date.civil(year, month, 1)
    @article = Article.find(:first, :conditions=>{:done_on=>start, :author_id=>session[:current_person_id]})
    if @article
      redirect_to :action=>:article_update, :id=>@article.id
    else
      session[:report_done_on] = start
      redirect_to :action=>:article_create, :rubric_id=>conf.news_rubric_id
    end
  end

  def story
    person_id = session[:current_person_id]
    person_id = params[:id] if params[:id] # and access?
    @author = Person.find_by_id(person_id)
    @reports = @author.reports
    expire_fragment(:controller=>:intra, :action=>:story, :id=>@author.id)
  end

  def report_help
    @samples = [ "un texte en **gras**...",
                 "en //italique//...", 
                 "en __souligné__...",
                 "en ''monospace''",
                 "ou **//__''tous à la fois''__//**",
                 "===== Titre de niveau 2 =====",
                 "==== Titre de niveau 3 ====",
                 "=== Titre de niveau 4 ===",
                 "Caractères spèciaux : * -> => <=> <= <- (C) (R)...",
                 "un exemple de site www.rotex1690.org",
                 "ou [[www.rotex1690.org]]",
                 "ou le site du [[www.rotex1690.org|Rotex 1690]]",
                 "un petit mail : <exemple@rotex1690.org>",
                 "un image centrée {{ image1 }}",
                 "un image alignée à gauche {{image1 |Titre de remplacement}}",
                 "un image alignée à droite {{ image1}}",
                 "  Texte largeur fixe avec 2 espace en début de ligne"
               ]
    
  end


  def period
    @person = Person.find_by_id(session[:current_person_id])
    if params[:id]
      @period = Period.find_by_person_id_and_id(@current_person.id, params[:id])
      unless @period
        redirect_to :action=>:folder, :id=>@person.id 
        return
      end
      @title = 'Modification de la période '+@period.name
    else
      @period = Period.new(:country_id=>@person.arrival_country_id)
      @title = 'Création d\'une période et famille '
    end
    if request.post?
      @period.attributes = params[:period]
      @period.person_id = session[:current_person_id]
      if @period.save
        redirect_to :action=>:folder, :id=>@person.id
      end
    end
  end

  def period_display
    @person = Person.find_by_id(session[:current_folder_id])
    if request.xhr?
      @period = Period.find_by_id_and_person_id(params[:id], @person.id)
      @owner_mode = (session[:current_person_id]==@person.id ? true : false)
      if @period
        key = @period.id.to_s
        session[:periods][key] = false if session[:periods][key].nil?
        session[:periods][key] = !session[:periods][key]
      end
      render :partial=>'period_display', :locals=>{:owner_mode=>@owner_mode}
    else
      redirect_to :action=>:folder, :id=>@person.id
    end
  end

  def period_delete
    if request.post? or request.delete?
      @person = Person.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
      period = Period.find_by_id_and_person_id(params[:id], session[:current_person_id])
      period.destroy unless period.nil?
      redirect_to :action=>:folder, :id=>@person.id
    end
  end

  def period_add_member
    @period = Period.find_by_id_and_person_id(params[:id], session[:current_person_id])
    if @period.nil?
      redirect_to :action=>:folder, :id=>session[:current_folder_id]
      return
    end
    @members = @current_person.members.find(:all, :order=>"last_name, first_name")||[]
    if request.post?
      @person = Person.find_by_id(session[:current_person_id])
      if params[:member][:id].nil?
        @member = Member.new(params[:member])
        @member.person_id = session[:current_person_id]
        if @member.save
          @period.members<< @member
          redirect_to :action=>:folder, :id=>@person.id
        end
      else
        @member = Member.find_by_id_and_person_id(params[:member][:id], session[:current_person_id])
        @period.members<< @member unless @period.members.exists? :id=>@member.id
        redirect_to :action=>:folder, :id=>@person.id
      end
    else
      @member = Member.new
    end
  end

  def period_remove_member
    @person = Person.find_by_id(session[:current_person_id])
    @period = Period.find_by_id_and_person_id(params[:period], session[:current_person_id])
    if @period.nil?
      redirect_to :action=>:folder, :id=>@person.id 
      return
    end
    @member = Member.find_by_id_and_person_id(params[:id], session[:current_person_id])
    if @member.nil?
      redirect_to :action=>:folder, :id=>@person.id 
      return
    end
    if request.post?
      @period.members.delete @member
    end
    redirect_to :action=>:folder, :id=>@person.id
  end




  def member
    @person = Person.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
    if params[:id]
      @member = Member.find_by_person_id_and_id(@current_person.id, params[:id])
      unless @member
        redirect_to :action=>:folder, :id=>@person.id 
        return
      end
      @title = 'Modification de '+@member.name
    else
      @member = Member.new()
      @title = 'Création d\'un membre '
    end
    if request.post?
      @member.attributes = params[:member]
      @member.person_id = session[:current_person_id]
      if @member.save
        redirect_to :action=>:folder, :id=>@person.id
      end
    end
  end



  hide_action :redirect_to_back
  def redirect_to_back
    if session[:history][1]
      session[:history].delete_at(0)
      redirect_to session[:history][0]
    else
      redirect_to :back
    end
  end
  

  hide_action :init_article
  def init_article(article, params, person)
    article.author_id ||= person.id
    article.language_id = params[:language_id]
    article.title = params[:title]
    article.intro = params[:intro]
    article.body  = params[:body]
    article.ready  = params[:ready]
    article.rubric_id  = params[:rubric_id]
    article.status = 'W' if article.new_record?
    article.status = params[:status] if access? :publishing
    # raise params[:agenda]+' '+params[:agenda].class.to_s
    article.done_on = params[:done_on]
  end


  def article_create
    if request.post?
      @article = Article.new
      # params[:article][:done_on] = session[:report_done_on] if session[:report_done_on].is_a? Date and !access?(:publishing)
      init_article(@article, params[:article], @current_person)
      @article.done_on = session[:report_done_on] if session[:report_done_on].is_a? Date and !access?(:publishing)
      # @article.natures = 'default' unless access? :publishing
      if @article.save
        # Mandate Nature à implémenter
        @article.mandate_natures.clear
        for k,v in params[:mandate_natures]||[]
          @article.mandate_natures << MandateNature.find(k) if v.to_s == "1"
        end
        redirect_to :action=>:profile
      end 
    else
      @article = Article.new(:rubric_id=>params[:rubric_id])
      @article.done_on = session[:report_done_on] if session[:report_done_on]
    end
  end
  
  def pick_image
    # @images = (access? ? Image.all : @current_person.images)
    @images = Image.all
    render :partial=>'pick_image'
  end


  def article_update
    @article = Article.find(params[:id])
    unless @article
      flash[:error] = "L'article demandé n'est pas disponible."
      redirect_to_back
      return
    end
    redirect_to :action=>:access_denied unless @article.author_id==@current_person.id or access? :publishing
    @article.to_correct if @article.ready?
    if @article.locked? and !access? :publishing
      flash[:warning] = "L'article a été validé par le rédacteur en chef et ne peut plus être modifié. Merci de votre compréhension."
      redirect_to :back
      return
    end
    if request.post?
      init_article(@article, params[:article], @current_person)
      if @article.save
        # Mandate Nature à implémenter
        @article.mandate_natures.clear
        for k,v in params[:mandate_natures]||[]
          @article.mandate_natures << MandateNature.find(k) if v.to_s == "1"
        end
        expire_fragment({:controller=>:home, :action=>:article_complete, :id=>@article.id})
        expire_fragment({:controller=>:home, :action=>:article_extract, :id=>@article.id})
        flash[:notice] = 'Vos modifications ont été enregistrées ('+I18n.localize(Time.now)+')'
        if params[:save_and_exit]
          redirect_to_back
        else
          redirect_to :back
        end
      end
    end
  end

  
  def article_edit
    redirect_to :action=>:article_update, :id=>params[:id]
  end
  
  def article_to_publish
    @article = Article.find(params[:id])
    if @article.author_id==@current_person.id or access? :publishing
      @article.to_publish
      redirect_to :back
    else
      redirect_to :action=>:access_denied 
    end
  end

  # copie de Home#article
  def article
    @article = Article.find(params[:id])
    if @article.nil?
      flash[:error] = "La page que vous demandez n'existe pas"
      redirect_to :action=>:index
    end
    if @current_person.nil? and not @article.public?
      flash[:error] = "Veuillez vous connecter pour accéder à l'article."
      redirect_to :controller=>:authentication, :action=>:login
    elsif @current_person
      # @article.published?
      unless @article.author_id == @current_person.id or @article.can_be_read_by?(@current_person) or access? :publishing
        @article = nil
        flash[:error] = "Vous n'avez pas le droit d'accéder à cet article."
        redirect_to :back
      end
    end
  end  


  def article_delete
    if request.post? or request.delete?
      @article = Article.find(params[:id])
      if @article.nil?
        flash[:error] = "La page que vous demandez n'existe pas"
      else
        Article.destroy(@article)
        flash[:notice] = "Article supprimé"
      end
    end
    redirect_to :back
  end



  def reports
    # expires_in 6.hours
    expires_now
    @countries = Country.find(:all, :select=>'distinct countries.*', :joins=>'JOIN people ON (countries.id=arrival_country_id)', :order=>:name)
    @zone_nature = ZoneNature.find(:first, :conditions=>["LOWER(name) LIKE 'zone se'"])
    @zones = Zone.find(:all, :joins=>"join countries AS co ON (zones.country_id=co.id)", :conditions=>["zones.nature_id=? AND LOWER(co.iso3166) LIKE 'fr'",@zone_nature.id], :order=>"number").collect {|p| [ p[:name], p[:id].to_i ] }||[]
    @zones.insert(0, ["-- Surligner les students d'une zone --",""])
    @zone = Zone.find_by_id(params[:id].to_i)
  end

  dyta(:students, :model=>:people, :conditions=>{:student=>true}, :order=>"family_name, first_name") do |t|
    t.column :first_name
    t.column :family_name
    t.column :name, :through=>:promotion
  end



  def students
    

    # @students = Person.find(:all, :conditions=>conditions, :order=>

  end




  
#   def person_create
#     if request.post?
#       @person = Person.new(params[:person])
#       if @person.save
#         redirect_to :action=>:persons
#       end
#     else
#       @person = Person.new
#     end
#     render_form
#   end
  
#   def person_update
#     @person = Person.find(params[:id])
#     if request.post?
#       if params[:person][:password].blank? and params[:person][:password_confirmation].blank?
#         params[:person].delete :password
#         params[:person].delete :password_confirmation
#       end
#       if @person.update_attributes(params[:person])
#         redirect_to :action=>:persons
#       end
#     end
#     render_form
#   end


  dyta(:people, :order=>"family_name, first_name", :per_page=>20, :line_class=>"(RECORD.is_locked ? 'error' : (RECORD.has_subscribed? ? 'notice' : (RECORD.has_subscribed_on? ? 'warning' : '')))") do |t|
    t.column :family_name, :url=>{:action=>:person}
    t.column :first_name, :url=>{:action=>:person}
    t.column :user_name
    t.column :address
    t.column :student
    t.action :is_locked, :actions=>{"true"=>{:action=>:person_unlock}, "false"=>{:action=>:person_lock}}
    t.action :person_update
    t.action :person_delete, :method=>:post, :confirm=>:are_you_sure
  end


  def people
    return unless try_to_access :users
    @title = "Liste des personnes"
    # @people = Person.paginate(:all, :order=>"family_name, first_name", :page=>params[:page], :per_page=>50)
  end

  def person
    return unless try_to_access [:users, :promotions]
    @person = Person.find_by_id(params[:id])
    redirect_to :action=>:people if @person.nil?
    @subscriptions = @person.subscriptions
    @mandates = @person.mandates
    @articles = @person.articles
  end
  
  def person_create
    return unless try_to_access :users
    if request.post?
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
        redirect_to :action=>:people
      end
    else
      @person = Person.new
    end
  end
  
  def person_update
    return unless try_to_access :users
    @person = Person.find(params[:id])
    if request.post?
      unless access? :all 
        params[:person][:password] = ''
        params[:person][:password_confirmation] = ''
      end
      @person.attributes = params[:person]
      @person.forced = true
      @person.email = params[:person][:email]
      if @person.save
        flash[:notice] = 'La personne '+@person.label+' a été modifiée'
        redirect_to :action=>:people
      end
    end
  end
  
  def person_lock
    return unless try_to_access :users
    p = Person.find(params[:id])
    p.is_locked = true
    p.forced    = true
    p.save!
    redirect_to :action=>:people
  end
  
  def person_unlock
    return unless try_to_access :users
    p = Person.find(params[:id])
    p.is_locked = false
    p.forced    = true
    p.save!
    redirect_to :action=>:people
  end
  
  def person_delete
    return unless try_to_access :users
    if request.post? or request.delete?
      begin
        Person.find(params[:id]).destroy 
      rescue
        flash[:warning] = "La personne n'a pas pu être supprimée"
      end
    end
    redirect_to :action=>:people
  end 

  def subscription_create
    return unless try_to_access :subscribing
    @person = Person.find(params[:id])
    if request.post?
      @subscription = Subscription.new(params[:subscription])
      @subscription.person_id = @person.id
      if @subscription.save
        session[:last_finished_on] = @subscription.finished_on
        Maily.deliver_has_subscribed(@person, @subscription)
        Maily.deliver_notification(:has_subscribed, @person, @current_person)
        redirect_to :action=>:person, :id=>@person.id
      end
    else
      @subscription = Subscription.new
      @subscription.finished_on = session[:last_finished_on] if session[:last_finished_on]
    end
  end

  def subscription_delete
    return unless try_to_access :subscribing
    s = Subscription.find(params[:id])
    s.destroy if request.post?
    redirect_to :action=>:person, :id=>s.person_id
  end

#   def subscribers
#     return unless try_to_access :subscribing
#     @title = "Liste des adhérents actuels"
#     @people = Person.paginate(:all, :joins=>"JOIN subscriptions ON (people.id=person_id)", :conditions=>["CURRENT_DATE BETWEEN begun_on AND finished_on"], :order=>:family_name, :page=>params[:page], :per_page=>50)
#     render :action=>:people
#   end

#   def non_subscribers
#     return unless try_to_access :subscribing
#     @title = "Liste des non-adhérents actuels"
#     @people = Person.paginate(:all, :conditions=>"id NOT IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE BETWEEN begun_on AND finished_on)", :order=>:family_name, :page=>params[:page], :per_page=>50)
#     render :action=>:people
#   end

#   def new_non_subscribers
#     return unless try_to_access :subscribing
#     @title = "Liste des futurs non-adhérents (à 2 mois)"
#     @people = Person.paginate(:all, :conditions=>"id NOT IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE+'2 months'::INTERVAL BETWEEN begun_on AND finished_on) AND id IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE BETWEEN begun_on AND finished_on)", :order=>:family_name, :page=>params[:page], :per_page=>50)
#     render :action=>:people
#   end

  def mandates
    @mandates = Mandate.all_current(:joins=>"JOIN mandate_natures mn ON (mn.id=nature_id) JOIN people p ON (person_id=p.id)", :order=>"mn.name, p.family_name, p.first_name")
  end

  def mandates_create
    return unless try_to_access :all
    @mandate = Mandate.new :person_id=>params[:id]

    if request.post?
      @mandate.attributes = params[:mandate]
      if @mandate.save
        redirect_to :action=>:mandates
      end
    end
  end

  def mandates_update
    return unless try_to_access :all
    @mandate = Mandate.find_by_id params[:id]
    redirect_to :action=>:mandates if @mandate.nil?
    if request.post?
      @mandate.attributes = params[:mandate]
      if @mandate.save
        redirect_to :action=>:mandates
      end
    end
  end

  def mandates_delete
    return unless try_to_access :all
    @mandate = Mandate.find(params[:id])
    if @mandate and request.post?
      Mandate.destroy(@mandate.id)
    end
    redirect_to :action=>:mandates
  end




  dyta(:promotion_people, :model=>:people, :order=>"family_name, first_name", :conditions=>{:promotion_id=>['session[:current_promotion_id]']}, :line_class=>"(RECORD.current? ? 'notice' : '')", :order=>"started_on DESC") do |t|
    t.action :folder, :image=>:show
    t.column :family_name, :url=>{:action=>:person}
    t.column :first_name, :url=>{:action=>:person}
    t.column :name, :through=>:promotion
    t.column :started_on
    t.column :stopped_on
    t.column :name, :through=>:proposer_zone
    t.column :name, :through=>:departure_country
    t.column :name, :through=>:arrival_country
    t.action :folder_delete, :method=>:delete, :confirm=>:are_you_sure, :if=>'!RECORD.student'
  end


  def promotions
    return unless try_to_access :promotions
    session[:current_promotion_id] ||= Promotion.first.id
    if request.post?
      @promotion = Promotion.find_by_id(params['promotion'].to_i)
      if @promotion
        session[:current_promotion_id] = @promotion.id 
      else
        session.delete :current_promotion_id
      end
#       conditions = {:promotion_id=>@promotion.id}
#       if access?
#         m = @current_person.mandate('rpz')
#         conditions[:proposer_zone_id] = m.zone.children.collect{|z| z.id} if m
#       end
#       @persons = Person.find(:all, :conditions=>conditions, :order=>'family_name, first_name')
    end
    @promotion = Promotion.find_by_id(session[:current_promotion_id])
  end




  # :conditions=>{:status=>['session[:articles_status]']}, 
  dyta(:articles, :joins=>"JOIN people ON (people.id=author_id)", :order=>"people.family_name, people.first_name, created_at DESC", :per_page=>20, :line_class=>"(RECORD.status.to_s == 'R' ? 'warning' : (Time.now-RECORD.updated_at <= 3600*24*30 ? 'notice' : ''))") do |t|
    t.column :title, :url=>{:action=>:article}
    t.column :name, :through=>:rubric, :url=>{:action=>:rubric}
    t.column :label, :through=>:author, :url=>{:action=>:person}
    t.column :updated_at
    t.action :status, :actions=>{"P"=>{:action=>:article_deactivate}, "R"=>{:action=>:article_activate}, "U"=>{:action=>:article_activate}, "W"=>{:action=>:article_update}, "C"=>{:action=>:article_update}}
    t.action :article_delete, :method=>:post,  :confirm=>"Sûr(e)\?"
  end


  def articles
    return unless try_to_access :publishing
    @title = "Tous les articles"
    if request.post?
      @article = Article.new(params[:article])
    end
  end


  def article_activate
    return unless try_to_access :publishing
    Article.find(params[:id]).publish
    redirect_to :back
  end

  def article_deactivate
    return unless try_to_access :publishing
    Article.find(params[:id]).unpublish
    redirect_to :back
  end



  dyta(:rubrics) do |t|
    t.column :name, :url=>{:action=>:rubric}
    t.column :code, :url=>{:action=>:rubric}
    t.column :description
    t.column :name, :through=>:parent
    t.action :rubric_update
    t.action :rubric_delete, :method=>:delete, :confirm=>:are_you_sure
  end

  def rubrics
    return unless try_to_access :publishing
  end

  def self.rubric_articles_conditions
    
    {:rubric_id=>['session[:current_rubric_id]']}
  end


  dyta(:rubric_articles, :model=>:articles, :conditions=>["rubric_id=? AND (amn.article_id IS NULL OR (amn.article_id IS NOT NULL AND m.person_id=? AND CURRENT_DATE BETWEEN COALESCE(m.begun_on, CURRENT_DATE) AND COALESCE(m.finished_on, CURRENT_DATE)))", ['session[:current_rubric_id]'], ['session[:current_person_id]']],  :joins=>"JOIN people ON (people.id=author_id) LEFT JOIN articles_mandate_natures AS amn ON (amn.article_id=articles.id) LEFT JOIN mandates AS m ON (m.nature_id=amn.mandate_nature_id)", :order=>"people.family_name, people.first_name, created_at DESC", :per_page=>20) do |t|
    t.column :title, :url=>{:action=>:article}
    t.column :label, :through=>:author, :url=>{:action=>:person}
    t.column :updated_at
    t.column :created_at
#    t.action :status, :actions=>{"P"=>{:action=>:article_deactivate}, "R"=>{:action=>:article_activate}, "U"=>{:action=>:article_activate}, "W"=>{:action=>:article_update}, "C"=>{:action=>:article_update}}
#    t.action :article_delete, :method=>:post,  :confirm=>"Sûr(e)\?"
  end

  def rubric
    @rubric = Rubric.find_by_id(params[:id])
    session[:current_rubric_id] = @rubric.id
  end

  manage :rubrics

  def preview
    @textile = params[:textile]||''
    @current_user = nil
    render :partial=>'preview' if request.xhr?
  end




  def zones_create
    @parent = Zone.find_by_id(params[:id])
    if @parent
      @natures = ZoneNature.find(:all, :conditions=>["parent_id=?", @parent.nature_id ], :order=>:name) 
    else
      @natures = ZoneNature.find(:all, :conditions=>["parent_id IS NULL"], :order=>:name) 
    end
    @parents = (@parent.nil? ? [] : @parent.parents)

    if request.post?
      @zone = Zone.new(params[:zone])
      @zone.parent_id = @parent.id if @parent
      @zone.save
    else
      @zone = Zone.new
      @zone.country_id = @parent.country_id if @parent
    end
    @zones = Zone.find(:all, :conditions=>(params[:id].nil? ? "parent_id IS NULL" : ["parent_id=?", params[:id]]), :order=>:name)
  end



  def zones_refresh
    zones = Zone.find(:all, :conditions=>["parent_id IS NULL"])
    for zone in zones
      zone.save
    end
    redirect_to :action=>:zones_create
  end






  def gallery
    if request.post?
      @image = Image.new(params[:image])
      @image.person_id =  session[:current_person_id]
      @image = Image.new if @image.save
    else
      @image = Image.new
    end
    
    @addable = (@current_person.images.size < @@images_count_per_person)
    @images = Image.find(:all, :conditions=>{:person_id=>session[:current_person_id]}, :order=>:title)
    render :partial=>'pick_image' if request.xhr?
  end


  def image_detail
    # @image = Image.find_by_id_and_person_id(params[:id], session[:current_person_id])
    @image = Image.find_by_id(params[:id])
    redirect_to :action=>:gallery if @image.nil?
  end

  def image_download
    # @image = Image.find_by_id_and_person_id(params[:id], session[:current_person_id])
    @image = Image.find_by_id(params[:id])
    redirect_to :action=>:gallery unless @image
  end

  def image_update
    @image = Image.find_by_id_and_person_id(params[:id], session[:current_person_id])
    if request.post?
      if @image.update_attributes(params[:image])
        redirect_to :action=>:gallery 
        return
      end
    end
    render :partial=>"image_form", :layout=>true
  end



  def image_delete
    image = Image.find_by_id_and_person_id(params[:id], session[:current_person_id])
    if image and image.deletable?
      Image.destroy(image.id) if request.delete?
    end
    redirect_to :action=>:gallery
  end


  def message_send
    @countries = Country.find(:all, :order=>:name)
    @promotions = Promotion.find(:all, :conditions=>{:is_outbound=>true}, :order=>:name)
    if request.post?
      begin
        Maily.deliver_message(@current_person, params[:mail])
        flash[:notice] = 'Votre message a été envoyé.'
        redirect_to :action=>:profile
      rescue
        flash[:error] = "Votre message n'a pas pu être envoyé."
      end
    end
  end


  def access_denied
  end



  
end

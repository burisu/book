class IntraController < ApplicationController

  before_filter :authorize
  cattr_reader :images_count_per_person
  @@images_count_per_person = 100


  def index
    profile
    render :action=>:profile
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


  dyta(:folders, :default_order=>"begun_on desc", :line_class=>"(RECORD.current? ? 'notice' : '')") do |t|
    t.action :folder, :image=>:show
    t.column :label, :through=>:person # , :url=>{:action=>:person}
    t.column :name, :through=>:promotion
    t.column :begun_on
    t.column :finished_on
    t.column :name, :through=>:proposer_zone
    t.column :name, :through=>:departure_country
    t.column :name, :through=>:arrival_country
    t.action :folder_delete, :method=>:delete, :confirm=>:are_you_sure, :if=>'!RECORD.person.student'
  end


  def folders
  end


  def folder
    person_id = session[:current_person_id]
    if access?(:folders) and params[:id]
      @folder = Folder.find_by_id(params[:id])
    elsif access?(:folders) and params[:person_id]
      person_id = params[:id].to_i 
    end
    @folder = Folder.find(:first, :conditions=>{:person_id=>person_id}) unless @folder
    unless @folder 
      redirect_to :action=>:folder_edit 
      return
    end
    session[:current_folder_id] = @folder.id
    @reports = []
    @periods = []
    @reports2 = {}
    session[:periods] ||= {}
    @owner_mode = (session[:current_person_id]==@folder.person_id ? true : false)

    
    if @folder
      start = @folder.begun_on.at_beginning_of_month
      stop = (Date.today<@folder.finished_on ? Date.today : @folder.finished_on)
      while start <= stop do
        article = Article.find(:first, :conditions=>{:done_on=>start, :author_id=>@folder.person_id})
        @reports << {:name=>start.year.to_s+'/'+start.month.to_s.rjust(2,'0'), :title=>(article.nil? ? "Créer" : article.title), :month=>start.year.to_s+start.month.to_s, :class=>(article.nil? ? "create" : nil)}
        @reports2[start.year.to_s] ||= []
        @reports2[start.year.to_s] << {:month=>I18n.translate('date.month_names')[start.month], 
          :name=>start.year.to_s+'/'+start.month.to_s.rjust(2,'0'), 
          :title=>(article.nil? ? "Créer" : article.title), 
          :id=>(article ? article.id : 0), 
          :month_id=>start.year.to_s+start.month.to_s, 
          :class=>(article.nil? ? "create" : nil)}
        start = start >> 1
        break if @reports.size>=24
      end
      @periods = @folder.periods.find(:all, :order=>:begun_on)
    end
    # raise Exception.new @folder.inspect
  end


  def folder_delete
    if request.post? or request.delete?
      @folder = Folder.find_by_id(params[:id])
      @folder.destroy unless @folder.nil?
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
      redirect_to :action=>:edit_report, :id=>@article.id
    else
      session[:report_done_on] = start
      redirect_to :action=>:new_report
    end
  end

  def story
    person_id = session[:current_person_id]
    person_id = params[:id] if params[:id] # and access?
    @folder = Folder.find(:first, :conditions=>{:person_id=>person_id})
    @reports = @folder.reports
    expire_fragment(:controller=>:intra, :action=>:story, :id=>@folder.id)
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
    @folder = Folder.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
    if params[:id]
      @period = Period.find_by_person_id_and_id(@current_person.id, params[:id])
      unless @period
        redirect_to :action=>:folder, :id=>@folder.id 
        return
      end
      @title = 'Modification de la période '+@period.name
    else
      @period = Period.new(:country_id=>@folder.arrival_country_id)
      @title = 'Création d\'une période et famille '
    end
    if request.post?
      @period.attributes = params[:period]
      @period.folder_id = @folder.id
      @period.person_id = session[:current_person_id]
      if @period.save
        redirect_to :action=>:folder, :id=>@folder.id
      end
    end
  end

  def period_display
    @folder = Folder.find_by_id(session[:current_folder_id])
    if request.xhr?
      @period = Period.find_by_id_and_person_id(params[:id], @folder.person_id)
      if @period
        key = @period.id.to_s
        session[:periods][key] = false if session[:periods][key].nil?
        session[:periods][key] = !session[:periods][key]
      end
      render :partial=>'period_display'
    else
      redirect_to :action=>:folder, :id=>@folder.id
    end
  end

  def period_delete
    if request.post? or request.delete?
      @folder = Folder.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
      period = Period.find_by_id_and_person_id(params[:id], session[:current_person_id])
      period.destroy unless period.nil?
      redirect_to :action=>:folder, :id=>@folder.id
    end
  end

  def period_add_member
    @period = Period.find_by_id_and_person_id(params[:id], session[:current_person_id])
    if @period.nil?
      redirect_to :action=>:folder 
      return
    end
    @members = @current_person.members.find(:all, :order=>"last_name, first_name")||[]
    if request.post?
      @folder = Folder.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
      if params[:member][:id].nil?
        @member = Member.new(params[:member])
        @member.person_id = session[:current_person_id]
        if @member.save
          @period.members<< @member
          redirect_to :action=>:folder, :id=>@folder.id
        end
      else
        @member = Member.find_by_id_and_person_id(params[:member][:id], session[:current_person_id])
        @period.members<< @member unless @period.members.exists? :id=>@member.id
        redirect_to :action=>:folder, :id=>@folder.id
      end
    else
      @member = Member.new
    end
  end

  def period_remove_member
    @folder = Folder.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
    @period = Period.find_by_id_and_person_id(params[:period], session[:current_person_id])
    if @period.nil?
      redirect_to :action=>:folder, :id=>@folder.id 
      return
    end
    @member = Member.find_by_id_and_person_id(params[:id], session[:current_person_id])
    if @member.nil?
      redirect_to :action=>:folder, :id=>@folder.id 
      return
    end
    if request.post?
      @period.members.delete @member
    end
    redirect_to :action=>:folder, :id=>@folder.id
  end




  def member
    @folder = Folder.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
    if params[:id]
      @member = Member.find_by_person_id_and_id(@current_person.id, params[:id])
      unless @member
        redirect_to :action=>:folder, :id=>@folder.id 
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
        redirect_to :action=>:folder, :id=>@folder.id
      end
    end
  end



  def folder_edit
    @folder = Folder.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
    @zone_nature = ZoneNature.find(:first, :conditions=>["LOWER(name) LIKE 'club'"])
    @zones = Zone.find(:all, :select=>"district.name||' - '||zones.name AS long_name, zones.id AS zid", :joins=>" join zones as zse on (zones.parent_id=zse.id) join zones as district on (zse.parent_id=district.id)", :conditions=>["zones.nature_id=?",@zone_nature.id], :order=>"district.name, zones.name").collect {|p| [ p[:long_name], p[:zid].to_i ] }||[]
    if @zones.empty?    
      flash[:warning] = 'Vous ne pouvez pas modifier votre voyage actuellement. Réessayez plus tard.'
      redirect_to :action=>:profile 
      return
    end
    if request.post?
      if @folder
        # Update
        params[:folder].delete :person_id
        @folder.attributes = params[:folder]
      else
        # Create
        @folder = Folder.new(params[:folder])
        @folder.person_id = session[:current_person_id]
      end
      if @folder.save
        redirect_to :action=>:folder, :id=>@folder.id
      end        
    else
      @folder ||= Folder.new
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
    article.status = 'W' if article.new_record?
    article.status = params[:status] if access? :publishing
    # raise params[:agenda]+' '+params[:agenda].class.to_s
    if access? :agenda
      article.natures_set :agenda, params[:agenda]=='1'
      article.done_on = params[:done_on]
    end
    article.natures_set :blog, params[:blog]=='1' if access? :blog
    article.natures_set :home, params[:home]=='1' if access? :home
    article.natures_set :contact, params[:contact]=='1' if access? :specials
    article.natures_set :about_us, params[:about_us]=='1' if access? :specials
    article.natures_set :legals, params[:legals]=='1' if access? :specials
  end


  def new_report
    if request.post?
      @article = Article.new
      # params[:article][:done_on] = session[:report_done_on] if session[:report_done_on].is_a? Date and !access?(:publishing)
      init_article(@article, params[:article], @current_person)
      @article.done_on = session[:report_done_on] if session[:report_done_on].is_a? Date and !access?(:publishing)
      @article.natures = 'default' unless access? :publishing
      redirect_to_back if @article.save
    else
      @article = Article.new
      @article.done_on = session[:report_done_on] if session[:report_done_on]
    end
  end
  
  def pick_image
    @images = @current_person.images
    render :partial=>'pick_image'
  end


  def edit_report
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
    redirect_to :action=>:edit_report, :id=>params[:id]
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
  def report_show
    @article = Article.find(params[:id])
    if @article.nil?
      flash[:error] = "La page que vous demandez n'existe pas"
      redirect_to :action=>:index
    end
    if @current_person.nil? and not @article.natures_include?(:home) and not @article.natures_include?(:agenda) and not @article.natures_include?(:about_us) and not @article.natures_include?(:contact) and not @article.natures_include?(:legals)
      flash[:error] = "Veuillez vous connecter pour accéder à l'article."
      redirect_to :controller=>:authentication, :action=>:login
    elsif @current_person
      unless @article.author_id == @current_person.id or access? :publishing or @article.published?
        @article = nil
        flash[:error] = "Vous n'avez pas le droit d'accéder à cet article."
        redirect_to :back
      end
    end
  end  


  def report_delete
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



  def all_reports
    # expires_in 6.hours
    expires_now
    @countries = Country.find(:all, :select=>'distinct countries.*', :joins=>'JOIN folders ON (countries.id=arrival_country_id)', :order=>:name)
    
  end




  
  def new_person
    if request.post?
      @person = Person.new(params[:person])
      if @person.save
        redirect_to :action=>:persons
      end
    else
      @person = Person.new
    end
  end
  
  def edit_person
    @person = Person.find(params[:id])
    if request.post?
      if params[:person][:password].blank? and params[:person][:password_confirmation].blank?
        params[:person].delete :password
        params[:person].delete :password_confirmation
      end
      if @person.update_attributes(params[:person])
        redirect_to :action=>:persons
      end
    end
  end

  def waiting_users
    try_to_access :user_validation
    @people = Person.paginate(:all, :conditions=>{:is_validated=>true, :is_locked=>true}, :page=>params[:page])
  end
  
  def people_browse
    try_to_access :users
    @title = "Liste des personnes"
    @people = Person.paginate(:all, :order=>"family_name, first_name", :page=>params[:page], :per_page=>50)
  end

  def people_select
    try_to_access [:users, :promotions]
    @person = Person.find_by_id(params[:id])
    redirect_to :action=>:people_browse if @person.nil?
    @subscriptions = @person.subscriptions
    @mandates = @person.mandates
    @articles = @person.articles
  end
  
  def people_create
    try_to_access :users
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
        redirect_to :action=>:people_browse
      end
    else
      @person = Person.new
    end
  end
  
  def people_update
    try_to_access :users
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
        redirect_to :action=>:people_browse
      end
    end
  end
  
  def people_lock_access
    try_to_access :users
    p = Person.find(params[:id])
    p.is_locked = true
    p.forced    = true
    p.save!
    redirect_to :action=>:people_browse
  end
  
  def people_unlock_access
    try_to_access :users
    p = Person.find(params[:id])
    p.is_locked = false
    p.forced    = true
    p.save!
    redirect_to :action=>:people_browse
  end
  
  def people_delete
    try_to_access :users
    if request.post? or request.delete?
      begin
        Person.find(params[:id]).destroy 
      rescue
        flash[:warning] = "La personne n'a pas pu être supprimée"
      end
    end
    redirect_to :action=>:people_browse
  end 

  def add_subscription
    try_to_access :subscribing
    @person = Person.find(params[:id])
    if request.post?
      @subscription = Subscription.new(params[:subscription])
      @subscription.person_id = @person.id
      if @subscription.save
        session[:last_finished_on] = @subscription.finished_on
        Maily.deliver_has_subscribed(@person, @subscription)
        Maily.deliver_notification(:has_subscribed, @person, @current_person)
        redirect_to :action=>:people_select, :id=>@person.id
      end
    else
      @subscription = Subscription.new
      @subscription.finished_on = session[:last_finished_on] if session[:last_finished_on]
    end
  end

  def remove_subscription
    try_to_access :subscribing
    s = Subscription.find(params[:id])
    s.destroy if request.post?
    redirect_to :action=>:people_select, :id=>s.person_id
  end

  def subscribers
    try_to_access :subscribing
    @title = "Liste des adhérents actuels"
    @people = Person.paginate(:all, :joins=>"JOIN subscriptions ON (people.id=person_id)", :conditions=>["CURRENT_DATE BETWEEN begun_on AND finished_on"], :order=>:family_name, :page=>params[:page], :per_page=>50)
    render :action=>:people_browse
  end

  def non_subscribers
    try_to_access :subscribing
    @title = "Liste des non-adhérents actuels"
    @people = Person.paginate(:all, :conditions=>"id NOT IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE BETWEEN begun_on AND finished_on)", :order=>:family_name, :page=>params[:page], :per_page=>50)
    render :action=>:people_browse
  end

  def new_non_subscribers
    try_to_access :subscribing
    @title = "Liste des futurs non-adhérents (à 2 mois)"
    @people = Person.paginate(:all, :conditions=>"id NOT IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE+'2 months'::INTERVAL BETWEEN begun_on AND finished_on) AND id IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE BETWEEN begun_on AND finished_on)", :order=>:family_name, :page=>params[:page], :per_page=>50)
    render :action=>:people_browse
  end

  def mandates
    @mandates = Mandate.all_current(:joins=>"JOIN mandate_natures mn ON (mn.id=nature_id) JOIN people p ON (person_id=p.id)", :order=>"mn.name, p.family_name, p.first_name")
  end

  def mandates_create
    try_to_access :all
    @mandate = Mandate.new :person_id=>params[:id]

    if request.post?
      @mandate.attributes = params[:mandate]
      if @mandate.save
        redirect_to :action=>:mandates
      end
    end
  end

  def mandates_update
    try_to_access :all
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
    try_to_access :all
    @mandate = Mandate.find(params[:id])
    if @mandate and request.post?
      Mandate.destroy(@mandate.id)
    end
    redirect_to :action=>:mandates
  end






  def promotions
    try_to_access :promotions
    if request.post?
      @promotion = Promotion.find(params['promotion'])
      conditions = {:promotion_id=>@promotion.id}
      if access?
        m = @current_person.mandate('rpz')
        conditions[:proposer_zone_id] = m.zone.children.collect{|z| z.id} if m
      end
      @folders = Folder.find(:all, :joins=>"JOIN people ON (people.id=person_id)", :conditions=>conditions, :order=>'family_name, first_name')
    end
  end





  def articles
    try_to_access :publishing
    @title = "Tous les articles"
    @articles = Article.paginate(:all, :joins=>"JOIN people ON (people.id=author_id)", :order=>"people.family_name, people.first_name, created_at DESC", :page=>params[:page])
  end

  def waiting_articles
    try_to_access :publishing
    @title = "Articles proposés à la publication"
    @articles = Article.paginate(:all, :conditions=>{:status=>'R'}, :joins=>"JOIN people ON (people.id=author_id)", :order=>"people.family_name, people.first_name, created_at DESC", :page=>params[:page])
    render :action=>:articles
  end

  def special_articles
    try_to_access :specials
    @title = "Articles spéciaux"
    @articles = Article.paginate(:all, :conditions=>"natures ILIKE '% legals %' OR natures ILIKE '% about_us %' OR natures ILIKE '% contact %'", :joins=>"JOIN people ON (people.id=author_id)", :order=>"people.family_name, people.first_name, created_at DESC", :page=>params[:page])
    render :action=>:articles
  end

  def agenda_articles
    try_to_access :agenda
    @title = "Articles de l'agenda"
    @articles = Article.paginate(:all, :conditions=>"natures ILIKE '% agenda %'", :joins=>"JOIN people ON (people.id=author_id)", :order=>"people.family_name, people.first_name, created_at DESC", :page=>params[:page])
    render :action=>:articles
  end

  def home_articles
    try_to_access :home
    @title = "Articles de la page d'accueil"
    @articles = Article.paginate(:all, :conditions=>"natures ILIKE '% home %'" , :joins=>"JOIN people ON (people.id=author_id)", :order=>"people.family_name, people.first_name, created_at DESC", :page=>params[:page])
    render :action=>:articles
  end

  def blog_articles
    try_to_access :home
    @title = "Articles extraits pour la présentation"
    @articles = Article.paginate(:all, :conditions=>"natures ILIKE '% blog %'" , :joins=>"JOIN people ON (people.id=author_id)", :order=>"people.family_name, people.first_name, created_at DESC", :page=>params[:page])
    render :action=>:articles
  end

  def other_articles
    try_to_access :publishing
    @title = "Autres articles (réservés aux membres)"
    @articles = Article.paginate(:all, :conditions=>"NOT (natures ILIKE '% legals %' OR natures ILIKE '% about_us %' OR natures ILIKE '% contact %' OR natures ILIKE '% blog %' OR natures ILIKE '% agenda %' OR natures ILIKE '% home %')" , :joins=>"JOIN people ON (people.id=author_id)", :order=>"people.family_name, people.first_name, created_at DESC", :page=>params[:page])
    render :action=>:articles
  end

  def article_activate
    try_to_access :publishing
    Article.find(params[:id]).publish
    redirect_to :back
  end

  def article_deactivate
    try_to_access :publishing
    Article.find(params[:id]).unpublish
    redirect_to :back
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
  end


  def image_detail
    @image = Image.find_by_id_and_person_id(params[:id], session[:current_person_id])
    redirect_to :action=>:gallery if @image.nil?
  end

  def image_download
    @image = Image.find_by_id_and_person_id(params[:id], session[:current_person_id])
    unless @image
      redirect_to :action=>:gallery 
      return
    end
  end


  def image_delete
    image = Image.find_by_id_and_person_id(params[:id], session[:current_person_id])
    if image
      Image.destroy(image.id)
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

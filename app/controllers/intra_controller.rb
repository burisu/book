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

  def folder
    @folder = Folder.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
    redirect_to :action=>:folder_edit unless @folder
    @reports = []
    @periods = []
    @reports2 = {}
    session[:periods] ||= {}
    
    if @folder
      start = @folder.begun_on.at_beginning_of_month
      stop = (Date.today<@folder.finished_on ? Date.today : @folder.finished_on)
      while start <= stop do
        article = Article.find(:first, :conditions=>{:done_on=>start, :author_id=>session[:current_person_id]})
        @reports << {:name=>start.year.to_s+'/'+start.month.to_s.rjust(2,'0'), :title=>(article.nil? ? "Créer" : article.title), :month=>start.year.to_s+start.month.to_s, :class=>(article.nil? ? "create" : nil)}
        @reports2[start.year.to_s] ||= []
        @reports2[start.year.to_s] << {:month=>I18n.translate('date.month_names')[start.month], :name=>start.year.to_s+'/'+start.month.to_s.rjust(2,'0'), :title=>(article.nil? ? "Créer" : article.title), :month_id=>start.year.to_s+start.month.to_s, :class=>(article.nil? ? "create" : nil)}
        start = start >> 1
        break if @reports.size>=24
      end
      @periods = @folder.periods.find(:all, :order=>:begun_on)
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

  def report_help
    @samples = [ "un texte en **gras**...",
                 "en //italique//...", 
                 "en __souligné__...",
                 "en ''monospace''",
                 "ou **//__''tous à la fois''__//**",
                 "===== Titre de niveau 2 =====",
                 "==== Titre de niveau 3 ====",
                 "=== Titre de niveau 4 ==="               ]
    
  end


  def period
    @folder = Folder.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
    if params[:id]
      @period = Period.find_by_person_id_and_id(@current_person.id, params[:id])
      redirect_to :action=>:folder unless @period
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
        redirect_to :action=>:folder
      end
    end
  end

  def period_display
    if request.xhr?
      @period = Period.find_by_id_and_person_id(params[:id], session[:current_person_id])
      if @period
        key = @period.id.to_s
        session[:periods][key] = false if session[:periods][key].nil?
        session[:periods][key] = !session[:periods][key]
      end
      render :partial=>'period_display'
    else
      redirect_to :action=>:folder
    end
  end

  def period_delete
    if request.post? or request.delete?
      period = Period.find_by_id_and_person_id(params[:id], session[:current_person_id])
      period.destroy unless period.nil?
      redirect_to :action=>:folder
    end
  end

  def period_add_member
    @period = Period.find_by_id_and_person_id(params[:id], session[:current_person_id])
    redirect_to :action=>:folder if @period.nil?
    @members = @current_person.members.find(:all, :order=>"last_name, first_name")||[]
    if request.post?
      if params[:member][:id].nil?
        @member = Member.new(params[:member])
        @member.person_id = session[:current_person_id]
        if @member.save
          @period.members<< @member
          redirect_to :action=>:folder
        end
      else
        @member = Member.find_by_id_and_person_id(params[:member][:id], session[:current_person_id])
        @period.members<< @member unless @period.members.exists? :id=>@member.id
        redirect_to :action=>:folder
      end
    else
      @member = Member.new
    end
  end

  def period_remove_member
    @period = Period.find_by_id_and_person_id(params[:period], session[:current_person_id])
    redirect_to :action=>:folder if @period.nil?
    @member = Member.find_by_id_and_person_id(params[:id], session[:current_person_id])
    redirect_to :action=>:folder if @member.nil?
    if request.post?
      @period.members.delete @member
    end
    redirect_to :action=>:folder
  end




  def member
    @folder = Folder.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
    if params[:id]
      @member = Member.find_by_person_id_and_id(@current_person.id, params[:id])
      redirect_to :action=>:folder unless @member
      @title = 'Modification de '+@member.name
    else
      @member = Member.new()
      @title = 'Création d\'un membre '
    end
    if request.post?
      @member.attributes = params[:member]
      @member.person_id = session[:current_person_id]
      if @member.save
        redirect_to :action=>:folder
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
        redirect_to :action=>:folder
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
  
  def new_report
    if request.post?
      @article = Article.new
      @article.init(params[:article], @current_person)
      @article.done_on = session[:report_done_on] if session[:report_done_on] === Date and !@current_person.can_manage?(:publishing)
      @article.natures = 'default' unless @current_person.can_manage? :publishing
      redirect_to_back if @article.save
    else
      @article = Article.new
      @article.done_on = session[:report_done_on] if session[:report_done_on]
    end
  end
  
  def edit_report
    @article = Article.find(params[:id])
    redirect_to :action=>:access_denied unless @article.author_id==@current_person.id or @current_person.can_manage? :publishing
    @article.to_correct if @article.ready?
    if @article.locked? and !@current_person.can_manage? :publishing
      flash[:warning] = "L'article a été validé par le rédacteur en chef et ne peut plus être modifié. Merci de votre compréhension."
      redirect_to :back
    end
    if request.post?
      @article.init(params[:article], @current_person)
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
    if @article.author_id==@current_person.id or @current_person.can_manage? :publishing
      @article.to_publish
      redirect_to :back
    else
      redirect_to :action=>:access_denied 
    end
  end

  def report_show
    @article = Article.find(params[:id])
    unless @article
      flash[:error] = "L'article que vous demandez n'existe pas"
      redirect_to :action=>:index
    end
  end  
  
  def persons
    if @current_person.role.restriction_level=0
      @persons = Person.find(:all,:order=>:user_name)
    else
      likes = Zone.find(:all, :joins=>"LEFT JOIN mandates ON (zone_id=zones.id)", :conditions=>["person_id=? AND ? BETWEEN begun_on AND finished_on", @current_person_id, Date.today]).collect{|z| "code LIKE '"+z.code+"%'"}.join(" OR ")
      likes = "zone_id IN (SELECT id FROM zones WHERE "+likes+") and " if likes.size>0
      @persons = Person.find(:all, :joins=>"join roles on (role_id=roles.id) left join mandates on (people.id=mandates.person_id)", :conditions=>[likes+"roles.restriction_level>?",@current_person.role.restriction_level], :order=>:patronymic_name)
    end
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
    access :user_validation
    @people = Person.paginate(:all, :conditions=>{:is_validated=>true, :is_locked=>true}, :page=>params[:page])
  end
  
  def people_browse
    access :users
    @title = "Liste des personnes"
    @people = Person.paginate(:all, :order=>"family_name, first_name", :page=>params[:page], :per_page=>50)
  end

  def people_select
    access :users
    @person = Person.find_by_id(params[:id])
    redirect_to :action=>:people_browse if @person.nil?
    @subscriptions = @person.subscriptions
    @mandates = @person.mandates
    @articles = @person.articles
  end
  
  def people_create
    access :users
    if request.post?
      params[:person][:role_id] = Role.none unless @current_person.can_manage? :all
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
    access :users
    @person = Person.find(params[:id])
    if request.post?
      unless @current_person.can_manage? :all 
        params[:person][:role_id] = @person.role_id 
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
    access :users
    p = Person.find(params[:id])
    p.is_locked = true
    p.forced    = true
    p.save!
    redirect_to :action=>:people_browse
  end
  
  def people_unlock_access
    access :users
    p = Person.find(params[:id])
    p.is_locked = false
    p.forced    = true
    p.save!
    redirect_to :action=>:people_browse
  end
  
  def people_delete
    access :users
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
    access :subscribing
    @person = Person.find(params[:id])
    if request.post?
      @subscription = Subscription.new(params[:subscription])
      @subscription.person_id = @person.id
      if @subscription.save
          session[:last_finished_on] = @subscription.finished_on
         redirect_to :action=>:people_select, :id=>@person.id
      end
    else
      @subscription = Subscription.new
      @subscription.finished_on = session[:last_finished_on] if session[:last_finished_on]
    end
  end

  def remove_subscription
    access :subscribing
    s = Subscription.find(params[:id])
    s.destroy if request.post?
    redirect_to :action=>:people_select, :id=>s.person_id
  end

  def subscribers
    access :subscribing
    @title = "Liste des adhérents actuels"
    @people = Person.paginate(:all, :joins=>"JOIN subscriptions ON (people.id=person_id)", :conditions=>["CURRENT_DATE BETWEEN begun_on AND finished_on"], :page=>params[:page], :per_page=>50)
    render :action=>:people_browse
  end

  def non_subscribers
    access :subscribing
    @title = "Liste des non-adhérents actuels"
    @people = Person.paginate(:all, :conditions=>"id NOT IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE BETWEEN begun_on AND finished_on)", :page=>params[:page], :per_page=>50)
    render :action=>:people_browse
  end

  def new_non_subscribers
    access :subscribing
    @title = "Liste des futurs non-adhérents (à 2 mois)"
    @people = Person.paginate(:all, :conditions=>"id NOT IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE+'2 months'::INTERVAL BETWEEN begun_on AND finished_on) AND id IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE BETWEEN begun_on AND finished_on)", :page=>params[:page], :per_page=>50)
    render :action=>:people_browse
  end

  def articles
    access :publishing
    @title = "Tous les articles"
    @articles = Article.paginate(:all, :order=>:created_at, :page=>params[:page])
  end

  def waiting_articles
    access :publishing
    @title = "Articles proposés à la publication"
    @articles = Article.paginate(:all, :conditions=>{:status=>'R'}, :order=>:created_at, :page=>params[:page])
    render :action=>:articles
  end

  def special_articles
    access :specials
    @title = "Articles spéciaux"
    @articles = Article.paginate(:all, :conditions=>"natures ILIKE '% legals %' OR natures ILIKE '% about_us %' OR natures ILIKE '% contact %'", :order=>:created_at, :page=>params[:page])
    render :action=>:articles
  end

  def agenda_articles
    access :agenda
    @title = "Articles de l'agenda"
    @articles = Article.paginate(:all, :conditions=>"natures ILIKE '% agenda %'", :order=>:created_at, :page=>params[:page])
    render :action=>:articles
  end

  def home_articles
    access :home
    @title = "Articles de la page d'accueil"
    @articles = Article.paginate(:all, :conditions=>"natures ILIKE '% home %'" , :order=>:created_at, :page=>params[:page])
    render :action=>:articles
  end

  def blog_articles
    access :home
    @title = "Articles extraits pour la présentation"
    @articles = Article.paginate(:all, :conditions=>"natures ILIKE '% blog %'" , :order=>:created_at, :page=>params[:page])
    render :action=>:articles
  end

  def other_articles
    access :publishing
    @title = "Autres articles (réservés aux membres)"
    @articles = Article.paginate(:all, :conditions=>"NOT (natures ILIKE '% legals %' OR natures ILIKE '% about_us %' OR natures ILIKE '% contact %' OR natures ILIKE '% blog %' OR natures ILIKE '% agenda %' OR natures ILIKE '% home %')" , :order=>:created_at, :page=>params[:page])
    render :action=>:articles
  end

  def article_activate
    access :publishing
    Article.find(params[:id]).publish
    redirect_to :back
  end

  def article_deactivate
    access :publishing
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

  




  def access_denied
  end



  
  protected
  
  def access(right=:all)
    redirect_to :action=>:access_denied unless @current_person.can_manage? right
  end
  
  
end

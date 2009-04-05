class IntraController < ApplicationController

  before_filter :authorize
	
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
      @person.forced = true
      if @person.update_attributes(params2)
        redirect_to :action=>:profile
      end
    end
  end

  def reporting
    @articles = Article.find(:all, :conditions=>{:author_id=>session[:current_person_id]}, :order=>"created_at DESC")
  end
  

  def folder
    @folder = Folder.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
    redirect_to :action=>:folder_edit unless @folder
    @reports = []
    @periods = []
    if @folder
      start = @folder.begun_on.at_beginning_of_month
      stop = (Date.today<@folder.finished_on ? Date.today : @folder.finished_on)
      while start <= stop do
        article = Article.find(:first, :conditions=>{:done_on=>start, :author_id=>session[:current_person_id]})
        @reports << {:title=>start.year.to_s+'/'+start.month.to_s.rjust(2,'0')+' - '+(article.nil? ? "Créer" : article.title_h), :month=>start.year.to_s+start.month.to_s}
        start = start >> 1
        break if @reports.size>=24
      end
      @periods = @folder.periods.find(:all, :order=>:begun_on)
    end
  end


  def report
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


  def period
    @folder = Folder.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
    if params[:id]
      @period = Period.find_by_person_id_and_id(@current_person.id, params[:id])
      redirect_to :action=>:folder unless @period
      @title = 'Modification de la période '+@period.name
    else
      @period = Period.new(:country_id=>@folder.arrival_country_id)
      @title = 'Création d\'une période '
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


  def folder_edit
    @folder = Folder.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
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
      @zone_nature = ZoneNature.find(:first, :conditions=>["LOWER(name) LIKE 'club'"])
    end
  end
  
  def new_report
    if request.post?
      @article = Article.new
      @article.init(params[:article], @current_person)
      @article.done_on = session[:report_done_on] if session[:report_done_on] === Date and !@current_person.can_manage?(:publishing)
      @article.natures = 'default' unless @current_person.can_manage? :publishing
      if @article.save
        redirect_to :action=>:reporting
      end
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
        flash[:notice] = 'Vos modifications ont été enregistrées ('+Time.now.to_s+')'
        redirect_to :back
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

  def show_report
    
    @article = Article.find(params[:id])
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
  




  def access_denied
  end



  
  protected
  
  def access(right=:all)
    redirect_to :action=>:access_denied unless @current_person.can_manage? right
  end
  
  
end

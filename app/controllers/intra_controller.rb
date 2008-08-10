class IntraController < ApplicationController

	before_filter :authorize
	
  def index
    profile
    render :action=>:profile
  end
  
  def profile
    @person=Person.find(session[:current_person_id])
  end

  def reporting
    @articles = Article.find(:all, :conditions=>{:author_id=>session[:current_person_id]}, :order=>"created_at DESC")
  end
  
  def admin
  end
  
  def new_folder
    if Folder.count(:conditions=>{:person_id=>@current_person.id, :is_accepted=>true})>0
      flash.now["warning"] = 'Vous avez déjà effectué un dossier.'
      redirect_to :back
    else
      
    end
  end
  
  def new_report
    if request.post?
      @article = Article.new
      @article.init(params[:article], @current_person)
      if @article.save
        redirect_to :action=>:reporting
      end
    else
      @article = Article.new
    end
  end
  
  def edit_report
    @article = Article.find(params[:id])
    if request.post?
      @article.init(params[:article], @current_person)
      if @article.save
        redirect_to :action=>:reporting
      end
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
    @people = Person.paginate(:all, :page=>params[:page])
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
  
  
  protected
  
  def access(right)
  end
  
  
end

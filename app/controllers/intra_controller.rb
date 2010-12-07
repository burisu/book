class IntraController < ApplicationController
  ssl_only

  before_filter :authorize
  cattr_reader :images_count_per_person
  @@images_count_per_person = 100

  dyli(:authors, [:first_name, :family_name, :user_name, :address], :model=>:people)


  def index
    profile
    render :action=>:profile
  end
  
  def approve
    @person = Person.find_by_id(params[:id])
    if @person and @person.salt==params[:xid]
      @person.approve!
      flash[:notice] = "La personne a été acceptée."
    else
      flash[:error] = "Vous n'avez pas le droit de faire cela."
    end
    redirect_to :action=>:index
  end

  def disapprove
    @person = Person.find_by_id(params[:id])
    if @person and @person.salt==params[:xid]
      @person.disapprove!
      flash[:notice] = "La personne a été verrouillée."
    else
      flash[:error] = "Vous n'avez pas le droit de faire cela."
    end
    redirect_to :action=>:index
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

  dyta(:person_mandates, :model=>:mandates, :conditions=>{:person_id=>['session[:current_person_id]']}, :order=>"begun_on DESC", :export=>false, :per_page=>5) do |t|
    t.column :name, :through=>:nature
    t.column :begun_on
    t.column :finished_on
  end

  dyta(:person_subscriptions, :model=>:subscriptions, :conditions=>{:person_id=>['session[:current_person_id]']}, :order=>"begun_on DESC", :export=>false, :per_page=>5) do |t|
    t.column :number, :class=>"code"
    t.column :begun_on
    t.column :finished_on
    t.column :payment_mode_label
    t.column :state_label
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
              pdf.image(person.photo("portrait"), :at=>[5, height-5], :fit=>[0.4*width-10, 0.8*height]) # , :width=>width, :height=>height)              
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



  def profile
    @person = Person.find(session[:current_person_id])
    if params[:mode] == "card"
      send_file visit_card(@person), :filename=>"#{@person.label}.pdf", :type=>"application/pdf"
    end
  end

  def profile_update
    @person = Person.find(session[:current_person_id])
    if request.post?
      params2 = {}
      if @current_person.admin?
        params2 = params[:person]||{}
      else
        [:address, :phone, :phone2, :fax, :mobile].each {|x| params2[x] = params[:person][x]}
      end
      @person.attributes = params2
      @person.forced = true
      if @person.save
        redirect_to :action=>:profile
      end
    end
  end



  def folder
    if params[:id].blank? or (not access?(:folders) and params[:id] != session[:current_person_id].to_s)
      flash[:error] = "Vous n'avez pas accès à ce dossier"
      redirect_to :back
      return
    end
    @person = Person.find_by_id(params[:id]) # session[:current_person_id]

    session[:current_folder_id] = @person.id
    @reports = []
    @periods = []
    @reports2 = {}
    session[:periods] ||= {}
    @owner_mode = (session[:current_person_id]==@person.id ? true : false)
    
    if @person
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
    @zones = Zone.list(["zones.nature_id=?",@zone_nature.id]) # find(:all, :select=>"co.name||' - '||district.name||' - '||zones.name AS long_name, zones.id AS zid", :joins=>" join zones as zse on (zones.parent_id=zse.id) join zones as district on (zse.parent_id=district.id) join countries AS co ON (zones.country_id=co.id)", :conditions=>["zones.nature_id=?",@zone_nature.id], :order=>"co.iso3166, district.name, zones.name").collect {|p| [ p[:long_name], p[:zid].to_i ] }||[]
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
    @zones = Zone.list(["zones.nature_id=?",@zone_nature.id]) # find(:all, :select=>"co.name||' - '||district.name||' - '||zones.name AS long_name, zones.id AS zid", :joins=>" join zones as zse on (zones.parent_id=zse.id) join zones as district on (zse.parent_id=district.id) join countries AS co ON (zones.country_id=co.id)", :conditions=>["zones.nature_id=?",@zone_nature.id], :order=>"co.iso3166, district.name, zones.name").collect {|p| [ p[:long_name], p[:zid].to_i ] }||[]
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
    article.author_id = params[:author_id]||person.id
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
    session[:person_key] = params[:person_key]||params[:key]
    session[:person_mode] = params[:mode]
    session[:person_state] = params[:state]
    session[:person_proposer_zone_id] = params[:proposer_zone_id].to_i
    session[:person_arrival_country_id] = params[:arrival_country_id].to_i
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




  dyta(:subscriptions, :order=>"state, created_at DESC", :line_class=>'RECORD.state_class' ) do |t|
    t.column :number, :class=>:code, :url=>{:action=>:subscription_update}
    # t.column :family_name, :through=>:person, :url=>{:action=>:person}
    # t.column :first_name, :through=>:person, :url=>{:action=>:person}
    t.column :label, :through=>:person, :url=>{:action=>:person}
    t.column :created_at
    t.column :amount
    t.column :begun_on
    t.column :finished_on
    t.column :state
    t.column :payment_mode
    t.action :subscription_delete, :method=>:delete, :confirm=>:are_you_sure
  end

  def subscriptions
    return unless try_to_access :subscribing
    if request.post?
      Subscription.delete_all(["state=? AND created_at<=? ", "I", Time.now - 48.hours])
    elsif request.put?
      @people = Subscription.chase_up
    end
  end


  def subscription_create
    return unless try_to_access :subscribing
    @person = Person.find(params[:id])
    if request.post?
      @subscription = Subscription.new(params[:subscription])
      @subscription.person_id = @person.id
      @subscription.responsible = @current_person
      if @subscription.save
        @subscription.person.approve!
        session[:last_finished_on] = @subscription.finished_on
        redirect_to :action=>:person, :id=>@person.id
      end
    else
      @subscription = Subscription.new
      @subscription.finished_on = session[:last_finished_on] if session[:last_finished_on]
    end
    @title = "Enregistrement d'une cotisation"
    render_form
  end

  def subscription_update
    return unless try_to_access :subscribing
    @subscription = Subscription.find(params[:id])
    if request.post?
      @subscription.attributes = params[:subscription]
      @subscription.responsible = @current_person
      if @subscription.save
        redirect_to :action=>:subscriptions
      end
    end
    @title = "Modification de la cotisation #{@subscription.number}"
    render_form
  end

  def subscription_delete
    return unless try_to_access :subscribing
    s = Subscription.find(params[:id])
    s.destroy if request.post? or request.delete?
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




  dyta(:promotion_people, :model=>:people, :order=>"family_name, first_name", :conditions=>"(session[:current_promotion_id].blank? ? {} : {:promotion_id=>session[:current_promotion_id]}).merge(:student=>true)", :line_class=>"(RECORD.current? ? 'notice' : '')", :order=>"started_on") do |t|
    t.action :folder, :image=>:show
    t.column :family_name, :url=>{:action=>:person}
    t.column :first_name, :url=>{:action=>:person}
    t.column :code, :through=>:promotion
    t.column :started_on, :label=>"Du"
    t.column :stopped_on, :label=>"Au"
    t.column :name, :through=>:proposer_zone
    t.column :name, :through=>:departure_country
    t.column :name, :through=>:arrival_country
    t.action :folder_delete, :method=>:delete, :confirm=>:are_you_sure, :if=>'!RECORD.student'
  end


  def promotions
    return unless try_to_access :promotions
    session[:current_promotion_id] = params[:id]
    @promotion = Promotion.find_by_id(session[:current_promotion_id]) unless session[:current_promotion_id].blank?
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
    t.column :name, :url=>{:action=>:rubric, :id=>"RECORD.code"}
    t.column :code, :url=>{:action=>:rubric, :id=>"RECORD.code"}
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


  dyta(:rubric_articles, :model=>:articles, :conditions=>["rubric_id=? AND status = 'P' AND (amn.article_id IS NULL OR (amn.article_id IS NOT NULL AND m.person_id=? AND CURRENT_DATE BETWEEN COALESCE(m.begun_on, CURRENT_DATE) AND COALESCE(m.finished_on, CURRENT_DATE)))", ['session[:current_rubric_id]'], ['session[:current_person_id]']],  :joins=>"JOIN people ON (people.id=author_id) LEFT JOIN articles_mandate_natures AS amn ON (amn.article_id=articles.id) LEFT JOIN mandates AS m ON (m.nature_id=amn.mandate_nature_id)", :order=>"people.family_name, people.first_name, created_at DESC", :per_page=>20) do |t|
    t.column :title, :url=>{:action=>:article}
    t.column :label, :through=>:author, :url=>{:action=>:person}
    t.column :updated_at
    t.column :created_at
#    t.action :status, :actions=>{"P"=>{:action=>:article_deactivate}, "R"=>{:action=>:article_activate}, "U"=>{:action=>:article_activate}, "W"=>{:action=>:article_update}, "C"=>{:action=>:article_update}}
#    t.action :article_delete, :method=>:post,  :confirm=>"Sûr(e)\?"
  end

  def rubric
    @rubric = Rubric.find_by_id(params[:id]) if params[:id].to_i > 0
    @rubric ||= Rubric.find_by_code(params[:id])
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
    if request.xhr?
      render :inline=>"<%=options_for_select(Promotion.find(:all, :conditions=>['id IN (SELECT promotion_id FROM people WHERE arrival_country_id=?)', params[:country_id]], :order=>:name).collect{|p| [p.name, p.id]}.insert(0, ['-- Toutes les promotions --', '']))-%>"
    else
      @countries = Country.find(:all, :conditions=>["id IN (SELECT arrival_country_id from people)"], :order=>:name)
      @promotions = Promotion.find(:all, :conditions=>['id IN (SELECT promotion_id FROM people WHERE arrival_country_id=?)', @countries[0].id], :order=>:name) # , :conditions=>{:is_outbound=>true}
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
  end


  def access_denied
  end



  
end

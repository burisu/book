# -*- coding: utf-8 -*-
class IntraController < ApplicationController
  ssl_only

  dyli(:authors, [:first_name, :family_name, :user_name, :address], :model=>:people)


  def index
    redirect_to myself_people_url
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
      redirect_to myself_people_url 
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
      redirect_to myself_people_url 
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
  def redirect_to_back()
    # if session[:history][1]
    #   session[:history].delete_at(0)
    #   redirect_to session[:history][0]
    # else
    redirect_to :back
    # end
  end
  
  def pick_image
    # @images = (access? ? Image.all : @current_person.images)
    @images = Image.all
    render :partial=>'pick_image'
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



#   def subscribers
#     # >> :subscribing
#     @title = "Liste des adhérents actuels"
#     @people = Person.paginate(:all, :joins=>"JOIN subscriptions ON (people.id=person_id)", :conditions=>["CURRENT_DATE BETWEEN begun_on AND finished_on"], :order=>:family_name, :page=>params[:page], :per_page=>50)
#     render :action=>:people
#   end

#   def non_subscribers
#     # >> :subscribing
#     @title = "Liste des non-adhérents actuels"
#     @people = Person.paginate(:all, :conditions=>"id NOT IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE BETWEEN begun_on AND finished_on)", :order=>:family_name, :page=>params[:page], :per_page=>50)
#     render :action=>:people
#   end

#   def new_non_subscribers
#     # >> :subscribing
#     @title = "Liste des futurs non-adhérents (à 2 mois)"
#     @people = Person.paginate(:all, :conditions=>"id NOT IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE+'2 months'::INTERVAL BETWEEN begun_on AND finished_on) AND id IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE BETWEEN begun_on AND finished_on)", :order=>:family_name, :page=>params[:page], :per_page=>50)
#     render :action=>:people
#   end









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
          redirect_to myself_people_url
        rescue
          flash[:error] = "Votre message n'a pas pu être envoyé."
        end
      end
    end
  end


  def access_denied
  end



  
end

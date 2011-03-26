# -*- coding: utf-8 -*-
class MyselvesController < ApplicationController

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
              


              pdf.image((person.photo("portrait") and File.exist?(person.photo("portrait")) ? person.photo("portrait") : File.join(RAILS_ROOT, "public", "images", "nobody.png")), :at=>[5, height-5], :fit=>[0.4*width-10, 0.8*height]) 
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
    @person = Person.find(session[:current_person_id])
    session[:person_id] = @person.id
    respond_to do |format|
      format.html
      format.pdf do
        send_file visit_card(@person), :filename=>"#{@person.label}.pdf", :type=>"application/pdf"
      end
    end
  end

  def edit
    @person = Person.find(session[:current_person_id])
    @title = "Modifier les informations de mon compte"
    render_form
  end

  def update
    @person = Person.find(session[:current_person_id])
    @title = "Modifier les informations de mon compte"
    params2 = {}
    if @current_person.admin?
      params2 = params[:person]||{}
    else
      [:address, :phone, :phone2, :fax, :mobile, :photo].each {|x| params2[x] = params[:person][x] if params[:person].has_key? x}
    end
    @person.attributes = params2
    @person.forced = true
    if @person.save
      redirect_to myself_url
    end
    render_form
  end

  def change_password
    @person = @current_person
    if request.post?
      @person.test_password = params[:person][:test_password]
      @person.password = params[:person][:password]
      @person.password_confirmation = params[:person][:password_confirmation]
      if @person.save
        flash[:notice] = 'Votre mot de passe a été mis à jour avec succès !'
        redirect_to myself_url
      end
    end
  end

  def change_email
    @person = @current_person
    if request.post?
      @person.test_password = params[:person][:test_password]
      @person.replacement_email = params[:person][:replacement_email]
      #      @person.errors.add(:test_password, "est incorrect") unless @person.confirm(params[:person][:test_password])
      if @person.save
        Maily.deliver_new_mail(@person)
        flash[:notice] = 'L\'e-mail à valider a été envoyé à l\'adresse '+@person.replacement_email
        redirect_to myself_url
      end
    end
  end

end

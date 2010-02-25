class SuiviController < ApplicationController
  before_filter :authorize, :except=>[:access_denied, :logout]

  def index
    # @questionnaires = Questionnaire.find(:all, :conditions=>["id IN (SELECT questionnaire_id FROM answers) OR CURRENT_DATE BETWEEN COALESCE(started_on, CURRENT_DATE-'1 day'::INTERVAL) AND COALESCE(stopped_on, CURRENT_DATE-'1 day'::INTERVAL)"])
    # @questionnaires = Questionnaire.find(:all, :conditions=>["id IN (SELECT questionnaire_id FROM answers) OR CURRENT_DATE BETWEEN COALESCE(started_on, CURRENT_DATE+'1 day'::INTERVAL) AND COALESCE(stopped_on, CURRENT_DATE+'1 day'::INTERVAL)"])
    @questionnaires = Questionnaire.of(@current_person)
  end


  dyta(:themes, :order=>:name) do |t|
    t.column :name
    t.column :color
    t.column :comment
    t.action :theme, :image=>:update
    t.action :theme, :image=>:destroy, :method=>:delete, :confirm=>"Are you sure\?"
  end

  def themes
    return unless try_to_access :suivi
  end

  def theme
    return unless try_to_access :suivi
    @theme = Theme.find_by_id(params[:id])
    @theme ||= Theme.new
    if request.post?
      @theme.attributes = params[:theme]
      redirect_to :action=>:themes if @theme.save
    elsif request.delete?
      @theme.destroy
      redirect_to :action=>:themes
    end
  end


  dyta(:questionnaires, :order=>"started_on DESC, name") do |t|
    t.column :name, :url=>{:action=>:questionnaire}
    t.column :started_on
    t.column :stopped_on
    t.column :active, :datatype=>:boolean
    t.column :questions_size
    t.column :answers_size, :url=>{:action=>:answers}
    t.action :questionnaire, :image=>:edit
    t.action :questionnaire_duplicate, :image=>:spread
    t.action :questionnaire, :image=>:destroy, :method=>:delete, :confirm=>"Are you sure\?"
  end

  def questionnaires
    return unless try_to_access :suivi
    @questionnaires = Questionnaire.find(:all, :order=>"started_on DESC, name")
  end

  dyta(:questionnaire_questions, :model=>:questions, :conditions=>{:questionnaire_id=>['session[:current_questionnaire]']}, :order=>'position') do |t|
    t.column :position
    t.column :name, :through=>:theme
    t.column :name
    t.column :explanation
    t.action :question_up, :if=>"!RECORD.first\? and !RECORD.questionnaire.active", :remote=>true, :update=>:questionnaire_questions
    t.action :question_down, :if=>"!RECORD.last\? and !RECORD.questionnaire.active", :remote=>true, :update=>:questionnaire_questions
    t.action :question, :image=>:edit, :if=>"!RECORD.questionnaire.active"
    t.action :question, :image=>:destroy, :method=>:delete, :confirm=>"Are you sure\?", :remote=>true, :update=>:questionnaire_questions, :if=>"!RECORD.questionnaire.active"
  end
  

  dyta(:questionnaire_answers, :model=>:answers, :joins=>"JOIN people ON (people.id=person_id)", :conditions=>["questionnaire_id=\?", ['session[:current_questionnaire]']], :per_page=>50, :order=>"family_name, first_name") do |t|
    t.column :label, :through=>:person
    t.column :status
    t.action :answers, :url=>{:anchor=>"'answer'+RECORD.id.to_s", :id=>"session[:current_questionnaire]"}, :image=>:search
    t.action :answer_delete, :method=>:delete
  end


  dyta(:questionnaire_students, :model=>:people, :conditions=>["student AND ? BETWEEN started_on AND stopped_on AND id NOT IN (SELECT person_id FROM answers WHERE questionnaire_id=?)", ['session[:current_questionnaire_started_on]'], ['session[:current_questionnaire]']], :per_page=>50, :order=>"family_name") do |t|
    t.column :family_name
    t.column :first_name
  end



  def questionnaire
    return unless try_to_access :suivi
    @questionnaire = Questionnaire.find_by_id(params[:id])
    @questionnaire = Questionnaire.new(:name=>'Nouveau questionnaire') unless @questionnaire
    @questions = @questionnaire.questions.find(:all, :order=>:position)
    if request.post?
      @questionnaire.update_attributes(params[:questionnaire])
    elsif request.delete?
      if @questionnaire.id and @questionnaire.answers_size<=0
        Questionnaire.destroy(@questionnaire)
        flash[:notice] = 'Suppression de '+@questionnaire.name+' effectuée'
      end
      redirect_to :action=>:questionnaires
    end
    session[:current_questionnaire] = @questionnaire ? @questionnaire.id : nil
    session[:current_questionnaire_started_on] = @questionnaire ? @questionnaire.started_on : nil
  end

  def absents_wake_up
    if request.post?
      questionnaire = Questionnaire.find_by_id(params[:id])
      people = Person.find(:all, :conditions=>["student AND ? BETWEEN started_on AND stopped_on AND id NOT IN (SELECT person_id FROM answers WHERE questionnaire_id=?)", session[:current_questionnaire_started_on], session[:current_questionnaire]])
      Maily.deliver_awakenings(people, questionnaire, @current_person)
    end
    redirect_to :action=>:questionnaire, :id=>questionnaire.id
  end



  def questionnaire_duplicate
    return unless try_to_access :suivi
    questionnaire = Questionnaire.find_by_id(params[:id])
    if questionnaire
      redirect_to :action=>:questionnaire, :id=>questionnaire.duplicate.id
      return
    end
    redirect_to :action=>:questionnaires
  end

  def question
    return unless try_to_access :suivi
    @question = Question.find_by_id(params[:id])
    @question = Question.new(:name=>'') unless @question
    @questionnaire = Questionnaire.find(session[:current_questionnaire])
    if request.post?
      params[:question][:questionnaire_id] = @questionnaire.id
      if @question.update_attributes(params[:question]) and not request.xhr?
        redirect_to :action=>:questionnaire, :id=>@question.questionnaire_id
      end
    elsif request.delete?
      if @question
        Question.destroy(@question)
        flash[:notice] = 'Suppression de '+@question.name+' effectuée'
      end
      redirect_to :action=>:questionnaire, :id=>@question.questionnaire_id unless request.xhr?
    end
    render :inline=>"<%=dyta(:questionnaire_questions)-%>" if request.xhr?
  end

  def question_up
    return unless try_to_access :suivi
    @question = Question.find_by_id(params[:id])
    @question.move_higher if @question
    if request.xhr?
      render :inline=>"<%=dyta(:questionnaire_questions)-%>" 
    else
      redirect_to :action=>:questionnaire, :id=>@question.questionnaire_id    
    end
  end
  
  def question_down
    return unless try_to_access :suivi
    @question = Question.find_by_id(params[:id])
    @question.move_lower if @question
    if request.xhr?
      render :inline=>"<%=dyta(:questionnaire_questions)-%>" 
    else
      redirect_to :action=>:questionnaire, :id=>@question.questionnaire_id    
    end
  end


  def answer
    @readonly = false
    @questionnaire = Questionnaire.find_by_id(params[:id])
    if @questionnaire.nil? #  or not @current_person.student
      flash[:error] = 'Page indisponible'
      redirect_to :action=>:index
      return
    end
    @answer = Answer.find_by_person_id_and_questionnaire_id(@current_person.id, @questionnaire.id)
    @answer = Answer.new(:person_id=>@current_person.id, :questionnaire_id=>@questionnaire.id) if @answer.nil?
    # @questions = @questionnaire.questions.find(:all, :select=>"questions.*, content AS answer", :joins=>"LEFT JOIN answer_items ON (questions.id=question_id) LEFT JOIN answers ON (answers.id=answer_id AND answer_id=#{@current_person.id})")
    # @questions = @questionnaire.questions.find(:all, :select=>"questions.*, content AS answer", :joins=>"LEFT JOIN answer_items ON (questions.id=question_id) LEFT JOIN answers ON (answers.id=answer_id)" , :conditions=>["answers.person_id=?", @current_person.id] )
    if @answer.locked or @answer.ready
      @readonly = true
    elsif request.post? and params[:question]
      @answer.save
      for k,v in params[:question]
        item = AnswerItem.find_by_question_id_and_answer_id(k.to_i, @answer.id)
        item = AnswerItem.new(:question_id=> k.to_i, :answer_id=>@answer.id) if item.nil?
        item.content = v[:answer]
        item.save
      end
      if params["save_and_ready"].to_s.size>0
        @answer.ready  = true 
        @answer.save!
        begin
          Maily.deliver_answer(@answer) if @answer
        rescue
        end
        redirect_to :action=>:index
        return
      end
    end
    # @questions = @questionnaire.questions.find(:all, :select=>"questions.*, content AS answer", :joins=>"LEFT JOIN answer_items ON (questions.id=question_id) LEFT JOIN answers ON (answers.id=answer_id)" , :conditions=>["answers.person_id=? OR answers.person_id IS NULL OR answer_id IS NULL", @current_person.id] )
    # @questions = @questionnaire.questions.find(:all, :select=>"questions.*, content AS answer", :joins=>"LEFT JOIN answer_items ON (questions.id=question_id)")
    @questions = @questionnaire.questions.find(:all, :select=>"questions.*, content AS answer", :joins=>"LEFT JOIN questionnaires AS qt ON (questions.questionnaire_id=qt.id) LEFT JOIN answers AS aws ON (aws.questionnaire_id=qt.id AND person_id=#{@current_person.id}) LEFT JOIN answer_items ON (questions.id=question_id AND answer_id=aws.id)")
  end
  

  def answers
    return unless try_to_access :suivi
    @questionnaire = Questionnaire.find_by_id(params[:id])
    @answers = @questionnaire.answers.find(:all, :order=>:id) # , :conditions=>{:ready=>true}
  end

  def answer_delete
    return unless try_to_access :suivi
    @answer = Answer.find_by_id(params[:id])
    @answer.destroy if request.post? or request.delete?
    redirect_to :action=>:questionnaire, :id=>@answer.questionnaire_id
  end

  def answer_lock
    return unless try_to_access :suivi
    @answer = Answer.find_by_id(params[:id])
    @answer.update_attribute(:locked, true) if request.post?
    redirect_to :action=>:answers, :id=>@answer.questionnaire_id, :anchor=>"answer#{@answer.id}"
  end

  def answer_unlock
    return unless try_to_access :suivi
    @answer = Answer.find_by_id(params[:id])
    @answer.update_attribute(:locked, false) if request.post?
    redirect_to :action=>:answers, :id=>@answer.questionnaire_id, :anchor=>"answer#{@answer.id}"
  end

  def answer_validate
    return unless try_to_access :suivi
    @answer = Answer.find_by_id(params[:id])
    @answer.update_attribute(:ready, true) if request.post?
    redirect_to :action=>:answers, :id=>@answer.questionnaire_id, :anchor=>"answer#{@answer.id}"
  end

  def answer_unvalidate
    return unless try_to_access :suivi
    @answer = Answer.find_by_id(params[:id])
    if request.post?
      @answer.update_attribute(:ready, false) 
      begin
        Maily.deliver_unvalidation(@answer, params[:message])
        flash[:notice] = "Le mail a été correctement envoyé"
      rescue Exception => e
        flash[:error] = "Le mail n'a pu être envoyé. "+e.message
      end
    end
    redirect_to :action=>:answers, :id=>@answer.questionnaire_id, :anchor=>"answer#{@answer.id}"
  end


  def access_denied
  end

end

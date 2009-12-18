class SuiviController < ApplicationController
  before_filter :authorize, :except=>[:access_denied, :logout]

  def index
    # @questionnaires = Questionnaire.find(:all, :conditions=>["id IN (SELECT questionnaire_id FROM answers) OR CURRENT_DATE BETWEEN COALESCE(started_on, CURRENT_DATE-'1 day'::INTERVAL) AND COALESCE(stopped_on, CURRENT_DATE-'1 day'::INTERVAL)"])
    # @questionnaires = Questionnaire.find(:all, :conditions=>["id IN (SELECT questionnaire_id FROM answers) OR CURRENT_DATE BETWEEN COALESCE(started_on, CURRENT_DATE+'1 day'::INTERVAL) AND COALESCE(stopped_on, CURRENT_DATE+'1 day'::INTERVAL)"])
    # Folder.find(:all, :conditions=>["CURRENT_DATE BETWE"])
    @questionnaires = Questionnaire.of(@current_person)
  end

  def questionnaires
    return unless try_to_access :suivi
    @questionnaires = Questionnaire.find(:all, :order=>"started_on DESC, name")
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
      if @question.update_attributes(params[:question])
        redirect_to :action=>:questionnaire, :id=>@question.questionnaire_id
      end
    elsif request.delete?
      if @question
        Question.destroy(@question)
        flash[:notice] = 'Suppression de '+@question.name+' effectuée'
      end
      redirect_to :action=>:questionnaire, :id=>@question.questionnaire_id
    end
  end

  def question_up
    return unless try_to_access :suivi
    @question = Question.find_by_id(params[:id])
    @question.move_higher if @question
    redirect_to :action=>:questionnaire, :id=>@question.questionnaire_id    
  end
  
  def question_down
    return unless try_to_access :suivi
    @question = Question.find_by_id(params[:id])
    @question.move_lower if @question
    redirect_to :action=>:questionnaire, :id=>@question.questionnaire_id    
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
      return
    end
    if request.post? and params[:question]
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
    @answers = @questionnaire.answers.find(:all, :conditions=>{:ready=>true})
  end

  def answer_unlock
    return unless try_to_access :suivi
    @answer = Answer.find_by_id(params[:id])
    if request.post?
      @answer.update_attribute(:locked, false)
      @answer.update_attribute(:ready, false)
      @answer.save!
    end
    redirect_to :action=>:answers, :id=>@answer.questionnaire_id
  end

  def access_denied
  end

end

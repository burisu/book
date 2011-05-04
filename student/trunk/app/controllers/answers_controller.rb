class AnswersController < ApplicationController

  def fill
    @readonly = false
    @questionnaire = Questionnaire.find_by_id(params[:id])
    if @questionnaire.nil? #  or not @current_person.student
      flash[:error] = 'Page indisponible'
      redirect_to :action=>:index
      return
    end
    @answer = Answer.find_by_person_id_and_questionnaire_id(@current_person.id, @questionnaire.id)
    @answer = Answer.new(:person_id=>@current_person.id, :questionnaire_id=>@questionnaire.id) if @answer.nil?
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
    @questions = @questionnaire.questions.find(:all, :select=>"questions.*, content AS answer", :joins=>"LEFT JOIN questionnaires AS qt ON (questions.questionnaire_id=qt.id) LEFT JOIN answers AS aws ON (aws.questionnaire_id=qt.id AND person_id=#{@current_person.id}) LEFT JOIN answer_items ON (questions.id=question_id AND answer_id=aws.id)")
  end

  def index
    @questionnaire = Questionnaire.find_by_id(params[:questionnaire_id])
    @answers = @questionnaire.answers.find(:all, :order=>:id) # , :conditions=>{:ready=>true}
  end

  def destroy
    @answer = Answer.find_by_id(params[:id])
    @answer.destroy
    redirect_to :action=>:questionnaire, :id=>@answer.questionnaire_id
  end

  def lock
    @answer = Answer.find_by_id(params[:id])
    @answer.update_attribute(:locked, true)
    redirect_to answers_url(:questionnaire_id=>@answer.questionnaire_id, :anchor=>"answer#{@answer.id}")
  end

  def unlock
    @answer = Answer.find_by_id(params[:id])
    @answer.update_attribute(:locked, false)
    redirect_to answers_url(:questionnaire_id=>@answer.questionnaire_id, :anchor=>"answer#{@answer.id}")
  end

  def accept
    @answer = Answer.find_by_id(params[:id])
    @answer.update_attribute(:ready, true)
    redirect_to answers_url(:questionnaire_id=>@answer.questionnaire_id, :anchor=>"answer#{@answer.id}")
  end

  def reject
    @answer = Answer.find_by_id(params[:id])
    @answer.update_attribute(:ready, false) 
    begin
      Maily.deliver_unvalidation(@answer, params[:message])
      flash[:notice] = "Le mail a été correctement envoyé"
    rescue Exception => e
      flash[:error] = "Le mail n'a pu être envoyé. "+e.message
    end
    redirect_to answers_url(:questionnaire_id=>@answer.questionnaire_id, :anchor=>"answer#{@answer.id}")
  end


end

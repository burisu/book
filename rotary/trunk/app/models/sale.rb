# == Schema Information
#
# Table name: sales
#
#  amount               :decimal(16, 2 
#  authorization_number :string(255)   
#  bin6                 :string(255)   
#  card_expired_on      :date          
#  card_type            :string(255)   
#  client_email         :string(255)   not null
#  client_id            :integer       
#  comment              :text          
#  country              :string(255)   
#  created_at           :datetime      
#  created_on           :date          not null
#  error_code           :string(255)   
#  id                   :integer       not null, primary key
#  lock_version         :integer       default(0)
#  number               :string(255)   not null
#  payer_country        :string(255)   
#  payment_mode         :string(255)   
#  payment_number       :string(255)   
#  payment_type         :string(255)   
#  sequential_number    :string(255)   
#  signature            :string(255)   
#  state                :string(255)   not null
#  transaction_number   :string(255)   
#  updated_at           :datetime      
#

# -*- coding: utf-8 -*-
class Sale < ActiveRecord::Base
  PAYMENT_MODES = [["Chèque", 'check'], ["Espèce","cash"], ["Carte bancaire", "card"], ["A payer", "none"]]
  ERROR_CODES = {
    "00000"=>"opération réussie.",
    "00003"=>"erreur e-transactions.",
    "00004"=>"numéro de porteur ou cryptogramme visuel invalide.",
    "00006"=>"accès refusé ou site/rang/identifiant incorrect.",
    "00008"=>"date de fin de validité incorrecte.",
    "00009"=>"erreur vérification comportementale",
    "00010"=>"devise inconnue.",
    "00011"=>"montant incorrect.",
    "00015"=>"paiement déjà effectué.",
    "00016"=>"inutilisé.",
    "00021"=>"Carte non autorisée.",
    "00030"=>"session contrôle sécurité expirée.",
    "00100"=>"transaction approuvée ou traitée avec succès.",
    "00102"=>"contacter l’émetteur de carte.",
    "00103"=>"commerçant invalide.",
    "00104"=>"conserver la carte.",
    "00105"=>"ne pas honorer.",
    "00107"=>"conserver la carte, conditions spéciales.",
    "00108"=>"approuver après identification du porteur.",
    "00112"=>"transaction invalide.",
    "00113"=>"montant invalide.",
    "00114"=>"numéro de porteur invalide.",
    "00115"=>"émetteur de carte inconnu.",
    "00117"=>"annulation client.",
    "00119"=>"répéter la transaction ultérieurement.",
    "00120"=>"réponse erronée (erreur dans le domaine serveur).",
    "00124"=>"mise à jour de fichier non supportée.",
    "00125"=>"impossible de localiser l’enregistrement dans le fichier.",
    "00126"=>"enregistrement dupliqué, ancien enregistrement remplacé.",
    "00127"=>"erreur en « edit » sur champ de mise à jour fichier.",
    "00128"=>"accès interdit au fichier.",
    "00129"=>"mise à jour de fichier impossible.",
    "00130"=>"erreur de format.",
    "00131"=>"identifiant de l’organisme acquéreur inconnu.",
    "00133"=>"date de validité de la carte dépassée.",
    "00134"=>"suspicion de fraude.",
    "00138"=>"nombre d’essais code confidentiel dépassé.",
    "00141"=>"carte perdue.",
    "00143"=>"carte volée.",
    "00151"=>"provision insuffisante ou crédit dépassé.",
    "00154"=>"date de validité de la carte dépassée.",
    "00155"=>"code confidentiel erroné.",
    "00156"=>"carte absente du fichier.",
    "00157"=>"transaction non permise à ce porteur.",
    "00158"=>"transaction interdite au terminal.",
    "00159"=>"suspicion de fraude.",
    "00160"=>"l’accepteur de carte doit contacter l’acquéreur.",
    "00161"=>"dépasse la limite du montant de retrait.",
    "00163"=>"règles de sécurité non respectées.",
    "00168"=>"réponse non parvenue ou reçue trop tard.",
    "00175"=>"nombre d’essais code confidentiel dépassé.",
    "00176"=>"porteur déjà en opposition, ancien enregistrement conservé.",
    "00190"=>"arrêt momentané du système.",
    "00191"=>"émetteur de cartes inaccessible.",
    "00194"=>"demande dupliquée.",
    "00196"=>"mauvais fonctionnement du système.",
    "00197"=>"échéance de la temporisation de surveillance globale.",
    "00198"=>"serveur inaccessible (positionné par le serveur).",
    "00199"=>"incident domaine initiateur."
  }
  STATES = [["Devis", 'I'], ["Commande","C"], ["Payée", "P"]]
  has_many :lines, :class_name=>SaleLine.name, :dependent=>:destroy
  has_many :passworded_lines, :class_name=>SaleLine.name, :conditions=>["products.passworded AND quantity>0"], :include=>:product
  apply_simple_captcha :message => "Le texte est différent de l'image de vérification", :add_to_base => true
  validates_uniqueness_of :number
  attr_readonly :number
  attr_accessor :client_email_confirmation
  validates_confirmation_of :client_email
  validates_numericality_of :amount
  validates_presence_of :amount

  def self.transaction_columns
    return {:amount=>"M", :number=>"R", :authorization_number=>"A", :sequential_number=>"T", :payment_type=>"P", :card_type=>"C", :transaction_number=>"S", :country=>"Y", :error_code=>"E", :card_expired_on=>"D", :payer_country=>"I", :bin6=>"N", :signature=>"K"}
  end



  def before_validation_on_create
    self.amount ||= 0.0
    self.state ||= STATES[0][1]
    if self.client
      self.client_email_confirmation = self.client_email = self.client.email
    end
    last = self.class.find(:first, :order=>"id DESC")
    self.number = Time.now.to_i.to_s(36)+(last ? last.id+1 : 0).to_s(36).rjust(6, '0')
    self.number.upcase!
    return true
  end

  def before_validation
    self.payment_mode ||= 'none'
    self.amount = self.lines.sum(:amount)
  end

  
  def validate
    errors.add(:payment_mode, :invalid) unless PAYMENT_MODES.collect{|x| x[1]}.include?(self.payment_mode)
  end

  def before_save
    @deliver_mail = false
    old_self = self.class.find_by_id(self.id.to_i)
    if (old_self.nil? or (old_self.is_a?(self.class) and old_self.state != self.state)) and self.state == "P"
      @deliver_mail = true
    end
  end
  
  def after_save
    if @deliver_mail
      Maily.deliver_has_subscribed(self.person, self)
      Maily.deliver_notification(:has_subscribed, self.person, self.responsible)
    end
  end

  def confirm
    self.update_attribute(:state, 'C')
  end

  def terminate
    if self.client and not self.client.approved?
      Maily.deliver_notification(:approval, self.client)
    end
    self.update_attribute(:state, 'P')
  end

  def paid?
    self.state == 'P'
  end

  def payment_mode_label
    PAYMENT_MODES.detect{|x| x[1] == self.payment_mode}[0]
  end

  def state_label
    {"I"=>"Devis", "C"=>"Commande", "P"=>"Payée"}[self.state]
  end

  def state_class
    {"I"=>"error", "C"=>"warning", "P"=>"notice"}[self.state]
  end
  
  def error_message
    ERROR_CODES[self.error_code]
  end  
  
  # Identifiant utilisé par les contrôleurs 
  def to_param
    self.number
  end
  
  def saleable_lines_for(person=nil)
    for product in Product.saleable_to(person)
      self.lines.create(:product_id=>product.id, :quantity=>0) unless self.lines.find_by_product_id(product.id)
    end
    self.reload
    return self.lines
  end

  
end

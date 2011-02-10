# == Schema Information
#
# Table name: payments
#
#  amount               :decimal(16, 2 default(0.0), not null
#  authorization_number :string(255)   
#  bin6                 :string(255)   
#  card_expired_on      :date          
#  card_type            :string(255)   
#  country              :string(255)   
#  created_at           :datetime      
#  error_code           :string(255)   
#  id                   :integer       not null, primary key
#  lock_version         :integer       default(0)
#  mode                 :string(255)   not null
#  number               :string(16)    
#  payer_country        :string(255)   
#  payer_email          :string(255)   not null
#  payer_id             :integer       
#  payment_type         :string(255)   
#  received             :boolean       not null
#  sequential_number    :string(255)   
#  signature            :string(255)   
#  transaction_number   :string(255)   
#  updated_at           :datetime      
#  used_amount          :decimal(16, 2 default(0.0), not null
#

# -*- coding: utf-8 -*-
class Payment < ActiveRecord::Base
  MODES = [["Chèque", 'check'], ["Espèce","cash"], ["Carte bancaire", "card"], ["A payer", "none"]]
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

  has_many :sales

  def self.transaction_columns
    return {:amount=>"M", :number=>"R", :authorization_number=>"A", :sequential_number=>"T", :payment_type=>"P", :card_type=>"C", :transaction_number=>"S", :country=>"Y", :error_code=>"E", :card_expired_on=>"D", :payer_country=>"I", :bin6=>"N", :signature=>"K"}
  end

  def before_validation
  end

  def validate
    errors.add(:mode, :invalid) unless MODES.collect{|x| x[1]}.include?(self.mode)
  end

  def error_message
    ERROR_CODES[self.error_code]
  end

  def payment_mode_label
    MODES.detect{|x| x[1] == self.mode}[0]
  end


end

namespace :rotex do

  task :migration => :environment do
    class LoadDefaultData < ActiveRecord::Migration
      def self.up
        langue=Language.create!(:name=>'Français', :native_name=>'Français', :iso639=>'FR')
        langue_en=Language.create!(:name=>'English', :native_name=>'English', :iso639=>'EN')
        langue_es=Language.create!(:name=>'Espagnol', :native_name=>'Español', :iso639=>'ES')
        pays=Country.create!(:name=>'France', :iso3166=>'FR', :language=>langue)
        pays=Country.create!(:name=>'Etats Unis', :iso3166=>'US', :language=>langue_en)
        pays=Country.create!(:name=>'Espagne', :iso3166=>'ES', :language=>langue_es)
        role=Role.create!(:name=>'Public', :code=>'public')
        role=Role.create!(:name=>'Administrator', :code=>'admin', :rights=>"all")

        params={}
        params[:patronymic_name]='ADMINISTRATEUR'
        params[:first_name]='Admin'
        params[:born_on]=Date.civil(2007,11,26)
        params[:address]='Bordeaux, France'
        params[:user_name]='rotadmin'
        params[:password]='r0t4dm|n'
        params[:password_confirmation]='r0t4dm|n'
        params[:country]=pays
        params[:role]=role
        params[:sex]='s'
        personne=Person.new(params)
        personne.email = 'bricetexier@yahoo.fr' # protected
        personne.is_user = true
        personne.is_validated = true
        personne.save!

        params={}
        params[:title]='Bienvenue'
        params[:intro]='Bla Intro (C) '*5
        params[:body]='Bla Content http://www.rotex1690.org essai de *gras* essai de "guillemet" _test_ "Rotex 1690":http://www.rotex1690.org. '*10
        params[:author]=personne
        params[:language]=langue
        params[:is_published]=true
        params[:natures]="home"
#        params[:nature]=art_nat
        article=Article.create!(params)
      end
    end
  end
  
  desc "Load default data Group/User"
  task :default => :migration do
    LoadDefaultData.up
  end

end


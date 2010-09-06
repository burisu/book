namespace :rotex do

  task :migration => :environment do
    class LoadDefaultData < ActiveRecord::Migration
      def self.up
        language=Language.create!(:name=>'Français', :native_name=>'Français', :iso639=>'FR')
        language_en=Language.create!(:name=>'English', :native_name=>'English', :iso639=>'EN')
        language_es=Language.create!(:name=>'Espagnol', :native_name=>'Español', :iso639=>'ES')
        country=Country.create!(:name=>'France', :iso3166=>'FR', :language=>language)
        country=Country.create!(:name=>'Etats Unis', :iso3166=>'US', :language=>language_en)
        country=Country.create!(:name=>'Espagne', :iso3166=>'ES', :language=>language_es)
        # role=Role.create!(:name=>'Public', :code=>'public')
        # role=Role.create!(:name=>'Administrator', :code=>'admin', :rights=>" all ")
        z1 = ZoneNature.create(:name=>'District')
        z2 = ZoneNature.create(:name=>'Zone SE', :parent_id=>z1.id)
        z3 = ZoneNature.create(:name=>'Club', :parent_id=>z2.id)
        m = MandateNature.create(:name=>'Youth Exchange Officer', :code=>'YEO', :zone_nature_id=>z1.id)
        m = MandateNature.create(:name=>'Président ROTEX', :code=>'PRX', :zone_nature_id=>z1.id)
        m = MandateNature.create(:name=>'Vice-Président ROTEX', :code=>'VPRX', :zone_nature_id=>z1.id)
        m = MandateNature.create(:name=>'Secrétaire ROTEX', :code=>'SRX', :zone_nature_id=>z1.id)
        m = MandateNature.create(:name=>'Trésorier ROTEX', :code=>'TRX', :zone_nature_id=>z1.id)
        m = MandateNature.create(:name=>'Administrateur', :code=>'ADM', :zone_nature_id=>z1.id)
        m = MandateNature.create(:name=>'Responsable de Zone', :code=>'RPZ', :zone_nature_id=>z2.id)
        m = MandateNature.create(:name=>'Président de club', :code=>'PCL', :zone_nature_id=>z3.id)
        m = MandateNature.create(:name=>'Délégué jeunesse', :code=>'DJ', :zone_nature_id=>z3.id)
        z = Zone.create(:name=>'District 1690', :number=>1690, :nature_id=>z1.id)
        14.times{|x| x += 1; Zone.create(:name=>'Zone '+x.to_s, :number=>x, :nature_id=>z1.id)}
        

        params={}
        params[:patronymic_name]='ADMINISTRATEUR'
        params[:first_name]='Admin'
        params[:born_on]=Date.civil(2007,11,26)
        params[:address]='Bordeaux, France'
        params[:user_name]='rotadmin'
        params[:password]='r0t4dm|n'
        params[:password_confirmation]='r0t4dm|n'
        params[:country]=country
        # params[:role]=role
        params[:sex]='s'
        person=Person.new(params)
        person.email = 'bricetexier@yahoo.fr' # protected
        person.is_user = true
        person.is_validated = true
        person.save!

        params={}
        params[:title]='Bienvenue'
        params[:intro]='Bla Intro (C) '*5
        params[:body]='Bla Content http://www.rotex1690.org essai de *gras* essai de "guillemet" _test_ "Rotex 1690":http://www.rotex1690.org. '*10
        params[:author]=person
        params[:language]=language
        params[:status]='P'
        params[:rubric_id]=Rubric.first.id rescue nil
        # params[:natures]=" home "
        # params[:nature]=art_nat
        article=Article.create!(params)
      end
    end
  end
  
  desc "Load default data Group/User"
  task :default => :migration do
    LoadDefaultData.up
  end

end


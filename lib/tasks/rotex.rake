namespace :rotex do

  namespace :base do

    task :migration => :environment do
      class LoadDefaultData < ActiveRecord::Migration

        langue=Language.create(:name=>'Français', :native_name=>'Français', :iso639=>'FR')
        langueEn=Language.create(:name=>'English', :native_name=>'English', :iso639=>'EN')
        langueEs=Language.create(:name=>'Espagnol', :native_name=>'Español', :iso639=>'ES')
        pays=Country.create(:name=>'France', :iso3166=>'FR', :language=>langue)
        pays=Country.create(:name=>'Etats Unis', :iso3166=>'US', :language=>langueEn)
        pays=Country.create(:name=>'Espagne', :iso3166=>'ES', :language=>langueEs)
        role=Role.create(:name=>'admin', :restriction_level=>0)

        params={}
        params[:patronymic_name]='ADMINISTRATEUR'
        params[:first_name]='Admin'
        params[:born_on]=Date.civil(2007,11,26)
        params[:home_address]='Rotex 1690 France'
        params[:user_name]='rotadmin'
        params[:email]='bricetexier@yahoo.fr'
        params[:password]='r0t4dm|n'
        params[:password_confirmation]='r0t4dm|n'
        params[:country]=pays
        params[:role]=role
        personne=Person.create(params)

#        Person.create(:patronymic_name=>'CONTACT', :first_name=>'Sys', :born_on=>Date.new(1970,1,1), :home_address=>'FRANCE', :user_name=>'contact', :email=>'rotex1690@gmail.com', :password=>'mlkjhg123FSDFSDF852', :password_confirmation=>'mlkjhg123FSDFSDF852',:role=>role,:country=>pays, :system=>true)
#        Person.create(:patronymic_name=>'SYSTEM', :first_name=>'Sys', :born_on=>Date.new(1970,1,1), :home_address=>'FRANCE', :user_name=>'system', :email=>'rotex1690@gmail.com', :password=>'5Y5Tem', :password_confirmation=>'5Y5Tem',:role=>role,:country=>pays, :system=>true)
#        Person.create(:patronymic_name=>'TEXIER', :first_name=>'Brice', :born_on=>Date.new(1983,12,12), :home_address=>'FRANCE', :user_name=>'brice', :email=>'bricetexier@yahoo.fr', :password=>'turion41', :password_confirmation=>'turion41',:role=>role,:country=>pays)
#        Person.create(:patronymic_name=>'TEXIER', :first_name=>'Brice', :born_on=>Date.new(1983,12,12), :home_address=>'FRANCE', :user_name=>'brice2', :email=>'brice.texier@fdsea33.fr', :password=>'turion41', :password_confirmation=>'turion41',:role=>role,:country=>pays)

        ArticleNature.create(:name=>'Article de carnet de bord', :code=>'BLOG')
        art_nat=ArticleNature.create(:name=>'Page accueil', :code=>'HOME')
        
#        zn1 = ZoneNature.create(:name=>"Univers")
#        zn2 = ZoneNature.create(:name=>"Galaxie", :parent_id=>zn1.id)
#        zn3 = ZoneNature.create(:name=>"Constellation", :parent_id=>zn2.id)
#        zn4 = ZoneNature.create(:name=>"Système planétaire", :parent_id=>zn3.id)
#        zn5 = ZoneNature.create(:name=>"Planète", :parent_id=>zn4.id)
        
#        z1 = Zone.create(:name=>"L'Univers",:number=>0, :nature_id=>zn1)
#        z2 = Zone.create(:name=>"La Voie Lactée",:number=>0, :nature_id=>zn2, :parent=>z1)
#        z3 = Zone.create(:name=>"La constellation du Soleil",:number=>0, :nature_id=>zn3, :parent=>z2)
#        z4 = Zone.create(:name=>"Le système solaire",:number=>0, :nature_id=>zn4, :parent=>z3)
#        z5 = Zone.create(:name=>"Terre",:number=>0, :nature_id=>zn5, :parent=>z4)
#        z5 = Zone.create(:name=>"Mars",:number=>1, :nature_id=>zn5, :parent=>z4)
        

        params={}
        params[:title]='Bienvenue'
        params[:intro]='Bla Intro (C) '*5
        params[:content]='Bla Content http://www.rotex1690.org essai de *gras* essai de "guillemet" _test_ "Rotex 1690":http://www.rotex1690.org '*10
        params[:author]=personne
        params[:language]=langue
        params[:nature]=art_nat
        article=Article.create(params)
                end
         
      end
    end

    desc "Load default data Group/User"
    task :up => :migration do
      LoadDefaultData.up
    end
  
  
  end
end


# == Schema Information
#
# Table name: images
#
#  created_at   :datetime      not null
#  desc         :string(255)   
#  desc_h       :text          
#  document     :string(255)   not null
#  id           :integer       not null, primary key
#  lock_version :integer       default(0), not null
#  name         :string(255)   not null
#  person_id    :integer       not null
#  title        :string(255)   not null
#  title_h      :text          not null
#  updated_at   :datetime      not null
#

class Image < ActiveRecord::Base
  
  file_column :document, :magick => {:versions => { "thumb" => "128x128", "medium" => "600x450>", "big"=>"1024x768>" } }

  validates_uniqueness_of :name

  def before_validation
    self.title_h = self.title.to_s
  end

  def before_validation_on_create
    self.name = self.title.lower_ascii.gsub(/\W/, '').to_s
    # while Image.find(:first, :conditions=>['id!=? AND name=?', self.id||0, self.name])
    while Image.find_by_name(self.name)
      self.name.succ!
    end
  end

end

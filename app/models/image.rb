# == Schema Information
# Schema version: 20090510103348
#
# Table name: images
#
#  id           :integer         not null, primary key
#  title        :string(255)     not null
#  title_h      :text            not null
#  desc         :string(255)     
#  desc_h       :text            
#  document     :string(255)     not null
#  person_id    :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#  name         :string(255)     not null
#

class Image < ActiveRecord::Base
  
  file_column :document, :magick => {:versions => { "thumb" => "128x128", "medium" => "600x450>", "big"=>"1024x768>" } }

  def before_validation
    self.name = self.title.lower_ascii.gsub(/\s/, '').to_s
    while Image.find(:first, :conditions=>['id!=? AND name=?', self.id||0, self.name])
      self.name.succ!
    end
    self.title_h = self.title.to_s
  end

end

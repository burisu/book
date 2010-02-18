# == Schema Information
#
# Table name: themes
#
#  color        :string(255)   default("#808080"), not null
#  comment      :text          
#  created_at   :datetime      
#  id           :integer       not null, primary key
#  lock_version :integer       default(0)
#  name         :string(255)   not null
#  updated_at   :datetime      
#

class Theme < ActiveRecord::Base
  
  def foreground_color
    Theme.gradient(self.color+"FF", "#00002260")
  end
  
  def background_color
    Theme.gradient(self.color+"FF", "#FFFFFFDD")
  end

  def self.ctoa(color)
    values = []
    for i in 0..3
      values << color.to_s[2*i+1..2*i+2].to_s.to_i(16).to_f
    end
    values
  end

  def self.atoc(color)
    code = '#'
    for x in 0..2
      code += color[x].to_i.to_s(16).rjust(2,"0")
    end
    code.upcase
  end

  def self.gradient(color1, color2)
    c1, c2 = Theme.ctoa(color1), Theme.ctoa(color2)
    r = []
    t = c2[3].to_f/255.to_f
    for i in 0..2
      r << c1[i]*(1-t)+c2[i]*t
    end
    return atoc(r)
  end
    
end

module ApplicationHelper

  def access?(right=:all)
    self.controller.access?(right)
  end

  def template_link_tag(name)
    code = ''
    ['screen', 'print'].each do |media|
      rel_path = "/templates/#{name}/stylesheets/#{media}.css"
      code += stylesheet_link_tag rel_path, :media=>media if File.exists?(File.join(Rails.public_path,rel_path))
    end
    code
  end

  def flash_tag(key=:error)
    if flash[key]
      content_tag :div, flash[key], :class=>'flash '+key.to_s
    else
      ''
    end
  end

end

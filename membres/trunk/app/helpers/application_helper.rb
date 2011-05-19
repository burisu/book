# -*- coding: undecided -*-
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

  def toolbar(input_id)
    selector = input_id+'_iselector'
    viewer = input_id+'_viewer'
    code = ''
    markups = [
               ['bold',      ' **',   '** ', 'texte en gras'], 
               ['italic',    ' //',   '// ', 'texte en italique'], 
               # ['underline', ' +',    '+ ' , 'texte souligné'], 
#               ['stroke',    ' -',    '- ' , 'texte rayé'], 
#               ['sup',       ' ^',    '^ ' , 'texte en exposant'], 
#               ['sub',       ' ~',    '~ ' , 'texte en indice'], 
               ['h1',        '\\n===== ', ' =====\\n'   , 'Titre de niveau 1'],
               ['h2',        '\\n==== ', ' ====\\n'   , 'Titre de niveau 2'],
               ['h3',        '\\n=== ', ' ===\\n'   , 'Titre de niveau 3'],
#               ['ul',        '\\n* ', ''   , 'Élément de liste à puce'], 
#               ['ol',        '\\n# ', ''   , 'Élément de liste numérotée'],
               ['link',      ' [[http://www.exemple.fr|', ']]' , 'site web'],
              ]
    code += content_tag(:div, nil, :id=>selector, :style=>"display:none;", :class=>'iselector')
    code += link_to_remote(image_tag('buttons/image.png'), {:url=>images_url(:editor=>input_id), :method=>:get,  :update=>"#{selector}", :success=>"$('#{selector}').show()"}, :class=>:tool)

    for markup, start, finish, middle in markups
      code += link_to_function(image_tag("buttons/#{markup}.png", :alt=>::I18n.t('general.layout.'+markup), :title=>::I18n.t('general.layout.'+markup)), "insertion($('#{input_id}'), '#{start}', '#{finish}', '#{middle}')", :class=>:tool)
    end

#    markup = 'image'
#    code += link_to_function(image_tag("buttons/#{markup}.png", :alt=>::I18n.t('general.layout.'+markup), :title=>::I18n.t('general.layout.'+markup)), "openImagePopup('#{url_for(:action=>:media, :id=>input_id)}', 'preview')", :class=>:tool)

    markup = 'show'
    code += link_to_remote(image_tag('buttons/show.png'), {:url=>preview_articles_url, :with=>"'textile=' + encodeURIComponent($('#{input_id}').value)", :update=>viewer, :success=>"$('#{viewer}').show()", :method=>:get}, :class=>:tool)
    code += link_to(image_tag('buttons/unknown.png'), help_articles_url, :class=>:tool)
    code = content_tag(:div, code, :class=>:editor)
    code = content_tag(:div, nil, :id=>viewer, :style=>"display:none;", :class=>'viewer')+code
  end



  def tl(label,field, options={})
    code  = content_tag('td',label,:class=>"label", :id=>options[:label_id])
    code += content_tag('td',field,:class=>"value", :id=>options[:value_id])
    hint  = ''
    hint += 'Ex&nbsp;: '+options[:example].to_s if options[:example]
    hint += '<br/>'if hint!='' and options[:hint]
    hint += 'Astuce&nbsp;: '+options[:hint].to_s if options[:hint]
    hint += '<br/>'if hint!='' and options[:info]
    hint += 'Info.&nbsp;: '+options[:info].to_s if options[:info]
    code += content_tag('td',hint, :class=>"hint", :id=>options[:hint_id])
    code  = content_tag('tr',code,:class=>cycle("odd","even"))
    code
  end

  def tt(label)
    code  = content_tag(:th, label, :colspan=>3)
    code  = content_tag(:tr, code)
    code
  end


end

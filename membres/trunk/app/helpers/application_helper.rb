# -*- coding: utf-8 -*-
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


  
  ENTITIES = {'(C)'=>'&copy;', '(R)'=>'&reg;', '(TM)'=>'<sup>TM</sup>', '(tm)'=>'<sup>tm</sup>','~'=>'&sim;', '->'=>'&rarr;', '<-'=>'&larr;', '<->'=>'&harr;', '=>'=>'&rArr;', '<='=>'&lArr;', '>>'=>'&raquo;', '<<'=>'&laquo;', '...'=>'&hellip;'}
  ALIGNS = {'  '=>'center', ' x'=>'right', 'x '=>'left', 'xx'=>''}

  def dokuwikize(text)
    content = text.to_s.dup
    content.gsub!(/\r/, '')
    content.gsub!('<=>', '&hArr;')
    ENTITIES.each{ |k,v| content.gsub!(k,v) }

    content.gsub!(/\-\-\-/, '&mdash;')
    content.gsub!(/\-\-/, '&ndash;')
    content.gsub!(/([^\=])\"([^\s][^\"]+[^\s])\"([^\>])/, '\1&ldquo;\2&rdquo;\3')

    content.gsub!(/\<([\w\-\.]+\@[\w\-\.]+)\>/) do |data|
   #   , '\1<a class="mail" href="http://\2" title="http://\2">\2</a>')
      data = data[1..-2]
#      '<a class="mail" title="'+data.gsub('@',' [at] ').gsub('.', ' [dot] ')+'" href="mailto:'+data.gsub('@','%20%5Bat%5D%20').gsub('.', '%20%5Bdot%5D%20')+'">'+data+'</a>'
      '<a class="mail" title="'+data.gsub('@',' [at] ').gsub('.', ' [dot] ')+'" href="mailto:'+data+'">'+data+'</a>'
    end

    content.gsub!(/\[\[([^\]\|]+)(\|[^\]]+)?\]\]/) do |data|
      data = data.squeeze(' ')[2..-3].split('|')
      url = data[0].strip
      caption = data[1] ? data[1].strip : url
      url = 'http://'+url unless url.match(/^[a-z]+\:\/\//)
      '<a class="urlextern" href="'+url+'" title="'+url+'">'+caption+'</a>'
    end    
    content.gsub!(/(\s|^)([a-z]+\:\/\/www\.[\w\-]+(\.[\w\-]+)+)/, '\1<a class="urlextern" href="\2" title="\2">\2</a>')
    content.gsub!(/([^\/])(www\.[\w\-]+(\.[\w\-]+)+)/, '\1<a class="urlextern" href="http://\2" title="http://\2">\2</a>')
    content.gsub!(/^  \* (.*)$/ , '<ul><li>\1</li></ul>')
    content.gsub!(/<\/ul>\n<ul>/ , '')
    content.gsub!(/^  \- (.*)$/ , '<ol><li>\1</li></ol>')
    content.gsub!(/<\/ol>\n<ol>/ , '')



    content.gsub!(/\{\{\ *(\w*)\ *(\|[^\}]+)?\}\}/) do |data|
      data = data.squeeze(' ')[2..-3].split('|')
      align = ALIGNS[(data[0][0..0]+data[0][-1..-1]).gsub(/[^\ ]/,'x')]
      image = Image.find_by_name(data[0].strip)
      title = data[1]
      if image.nil?
        "**<span class=\"e\">Image introuvable (#{data})</span>**"
      else
        alt = title||image.title
        code  = '<img class="media'+align+'"'
        # code += ' align="'+align+'"' if ['left', 'right'].include? align
        code += ' alt="'+alt+'" title="'+alt+'"'
        code += ' src="'+ActionController::Base.relative_url_root.to_s+'/'+image.document_options[:base_url]+'/'+image.document_relative_path('thumb')+'"/>'
        code = link_to(code, image_url(image), {:class=>:media})
        code = '<div class="media media'+align+'">'+code+'<div class="title">'+h(title)+'</div></div>' if title
        code
      end
    end

    for x in 2..5
      n = 7-x
      content.gsub!(/\={#{n}}([^\=]+)\={#{n}}/, "<h#{x}>\\1</h#{x}>")
    end

    content.gsub!(/^\ \ (.+)$/, '  <pre>\1</pre>')
    # content.gsub!("</pre>\n  <pre>", "\n")

    content.gsub!(/(^|[^\*])\*([^\*]|$)/, '\1&lowast;\2')
    content.gsub!(/([^\:])\/\/([^\s][^\/]+)\/\//, '\1<em>\2</em>')
    content.gsub!(/\'\'([^\s][^\']+)\'\'/, '<code>\1</code>')
    content.gsub!(/\_\_([^\s][^\_]+)\_\_/, '<span class="u">\1</span>')
    content.gsub!(/(^)([^\s\<][^\s].*)($)/, '<p>\2</p>')
    content.gsub!("</p>\n<p>", "\n")
    content.gsub!(/\*\*([^\s][^\*]+)\*\*/, '<strong>\1</strong>')
    return content+'<div style="height:8px; clear:both;"></div>'
  end
  




end

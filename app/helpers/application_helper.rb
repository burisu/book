module ApplicationHelper
  # Fournit la liste des pays
  def countries
    I18n.translate(:countries).collect{|k,v| [v, k]}.sort
  end

  def back_url
    :back
  end

  def page_title
    if @title
      return content_tag(:h1, @title, :id=>:title)
    end
    
    return ''
  end

  def country(code)
    image_tag("countries/"+code+".png")+' '+I18n.translate('countries.'+code)
  end


  def fieldset(legend = nil, html_options={}, &block)
    html = ""
    html << content_tag(:legend, tg(legend))
    if block_given?
      html << capture(&block)
    end
    return content_tag(:fieldset, html.html_safe, html_options)
  end

  def authorized?(url={})
    true
  end

  def theme_button(name)
    "buttons/#{name}.png"
  end

  # TOOLBAR

  def toolbar(options={}, &block)
    code = '[EmptyToolbarError]'
    if block_given?
      toolbar = Toolbar.new
      if block
        if block.arity < 1
          self.instance_values.each do |k,v|
            toolbar.instance_variable_set("@" + k.to_s, v)
          end
          toolbar.instance_eval(&block)
        else
          block[toolbar] 
        end
      end
      toolbar.link :back if options[:back]
      # To HTML
      code = ''
      # call = 'views.' << caller.detect{|x| x.match(/\/app\/views\//)}.split(/\/app\/views\//)[1].split('.')[0].gsub(/\//,'.') << '.'
      for tool in toolbar.tools
        nature, args = tool[0], tool[1]
        if nature == :link
          name = args[0]
          args[1] ||= {}
          args[2] ||= {}
          # args[2][:class] ||= "icon im-" + name.to_s.split('_')[-1]
          args[0] = ::I18n.t("actions.#{args[1][:controller]||controller_name}.#{name}".to_sym, {:default=>["labels.#{name}".to_sym]}.merge(args[2].delete(:i18n)||{})) if name.is_a? Symbol
          if name.is_a? Symbol and name!=:back
            args[1][:action] ||= name
            args[2][:class] = "icon im-" + args[1][:action].to_s if args[1][:action]
          else
            args[2][:class] = "icon im-" + args[1][:action].to_s.split('_')[-1] if args[1][:action]
          end
          code << content_tag(:div, link_to(*args), :class=>:tool) if authorized?(args[1])
        elsif nature == :print
          dn, args, url = tool[1], tool[2], tool[3]
          url[:controller] ||= controller_name
          for dt in @current_company.document_templates.find(:all, :conditions=>{:nature=>dn.to_s, :active=>true}, :order=>:name)
            code << content_tag(:div, link_to(tc(:print_with_template, :name=>dt.name), url.merge(:template=>dt.code), :class=>"icon im-print"), :class=>:tool) if authorized?(url)
          end
        elsif nature == :mail
          args[2] ||= {}
          args[2][:class] = "icon im-mail"
          code << content_tag(:div, mail_to(*args), :class=>:tool)
        elsif nature == :missing
          verb, record, tag_options = tool[1], tool[2], tool[3]
          action = verb # "#{record.class.name.underscore}_#{verb}"
          tag_options = {} unless tag_options.is_a? Hash
          tag_options[:class] = "icon im-#{verb}"
          url = {}
          url.update(tag_options.delete(:params)) if tag_options[:params].is_a? Hash
          url[:controller] ||= controller_name
          url[:action] = action
          url[:id] = record.id
          code << content_tag(:div, link_to(t("actions.#{url[:controller]}.#{action}", record.attributes.symbolize_keys), url, tag_options), :class=>:tool) if authorized?(url)
        end
      end
      if code.strip.length>0
        # code = content_tag(:ul, code.html_safe) << content_tag(:div)
        # code = content_tag(:h2, t(call << options[:title].to_s)) << code if options[:title]
        code = content_tag(:div, code.html_safe, :class=>'toolbar' + (options[:class].nil? ? '' : ' ' << options[:class].to_s)) + content_tag(:div, nil, :class=>:clearfix)
      end
    else
      raise Exception.new('No block given for toolbar')
    end
    return code.html_safe
  end

  class Toolbar
    attr_reader :tools

    def initialize()
      @tools = []
    end

    def link(*args)
      @tools << [:link, args]
    end

    def mail(*args)
      @tools << [:mail, args]
    end
    
    def method_missing(method_name, *args, &block)
      raise ArgumentError.new("Block can not be accepted") if block_given?
      if method_name.to_s.match(/^print_\w+$/)
        nature = method_name.to_s.gsub(/^print_/, '').to_sym
        raise Exception.new("Cannot use method :print_#{nature} because nature '#{nature}' does not exist.") unless parameters = DocumentTemplate.document_natures[nature]
        url = args.delete_at(-1) if args[-1].is_a?(Hash)
        raise ArgumentError.new("Parameters don't match. #{parameters.size} expected, got #{args.size} (#{[args, options].inspect}") unless args.size == parameters.size
        url ||= {}
        url[:action] ||= :show
        url[:format] = :pdf
        url[:id] ||= args[0].id if args[0].respond_to?(:id) and args[0].class.ancestors.include?(ActiveRecord::Base)
        url[:n] = nature
        parameters.each_index do |i|
          url[parameters[i][0]] = args[i]
        end
        @tools << [:print, nature, args, url]
      else
        raise ArgumentError.new("First argument must be an ActiveRecord::Base. (#{method_name})") unless args[0].class.ancestors.include? ActiveRecord::Base
        @tools << [:missing, method_name, args[0], args[1]]
      end
    end
  end


end

# -*- coding: utf-8 -*-
module ApplicationHelper
  # Fournit la liste des pays
  def countries
    I18n.translate(:countries).collect{|k,v| [v, k]}.sort
  end

  def back_url
    :back
  end

  def page_title
    return content_tag(:h1, I18n.translate("actions.#{controller_name}.#{action_name}"), :id=>:title)
    
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









  def attribute_item(object, attribute, options={})
    value_class = 'value'
    if object.is_a? String
      label = object
      value = attribute
      value = value.to_s unless [String, TrueClass, FalseClass].include? value.class
    else
      #     label = object.class.human_attribute_name(attribute.to_s)
      value = object.send(attribute)
      model_name = object.class.name.underscore
      default = ["activerecord.attributes.#{model_name}.#{attribute.to_s}_id".to_sym]
      default << "activerecord.attributes.#{model_name}.#{attribute.to_s[0..-7]}".to_sym if attribute.to_s.match(/_label$/)
      default << "attributes.#{attribute.to_s}".to_sym
      default << "attributes.#{attribute.to_s}_id".to_sym
      label = ::I18n.translate("activerecord.attributes.#{model_name}.#{attribute.to_s}".to_sym, :default=>default)
      if value.is_a? ActiveRecord::Base
        record = value
        value = record.send(options[:label]||[:label, :name, :code, :number, :inspect].detect{|x| record.respond_to?(x)})
        options[:url] = {:action=>:show} if options[:url].is_a? TrueClass
        if options[:url].is_a? Hash
          options[:url][:id] ||= record.id
          # raise [model_name.pluralize, record, record.class.name.underscore.pluralize].inspect
          options[:url][:controller] ||= record.class.name.underscore.pluralize
        end
      else
        options[:url] = {:action=>:show} if options[:url].is_a? TrueClass
        if options[:url].is_a? Hash
          options[:url][:controller] ||= object.class.name.underscore.pluralize
          options[:url][:id] ||= object.id
        end
      end
      value_class  <<  ' code' if attribute.to_s == "code"
    end
    if [TrueClass, FalseClass].include? value.class
      value = content_tag(:div, "", :class=>"checkbox-#{value}")
    elsif attribute.match(/(^|_)currency$/)
      value = ::Numisma[value].label
    elsif options[:currency] and value.is_a?(Numeric)
      value = ::I18n.localize(value, :currency=>options[:currency])
      value = link_to(value.to_s, options[:url]) if options[:url]
    elsif value.respond_to?(:strftime) or value.is_a?(Numeric)
      value = ::I18n.localize(value)
      value = link_to(value.to_s, options[:url]) if options[:url]
    elsif options[:duration]
      duration = value
      duration = duration*60 if options[:duration]==:minutes
      duration = duration*3600 if options[:duration]==:hours
      hours = (duration/3600).floor.to_i
      minutes = (duration/60-60*hours).floor.to_i
      seconds = (duration - 60*minutes - 3600*hours).round.to_i
      value = tg(:duration_in_hours_and_minutes, :hours=>hours, :minutes=>minutes, :seconds=>seconds)
      value = link_to(value.to_s, options[:url]) if options[:url]
    elsif value.is_a? String
      classes = []
      classes << "code" if attribute.to_s == "code"
      classes << value.class.name.underscore
      value = link_to(value.to_s, options[:url]) if options[:url]
      value = content_tag(:div, value.html_safe, :class=>classes.join(" "))
    end
    return label, value
  end


  def attributes_list(record, options={}, &block)
    columns = options[:columns] || 3
    attribute_list = AttributesList.new
    raise ArgumentError.new("One parameter needed") unless block.arity == 1
    yield attribute_list if block_given?
    code = ""
    size = attribute_list.items.size
    if size > 0
      column_height = (size.to_f/columns.to_f).ceil

      column_height.times do |c|
        line = ""
        columns.times do |i|
          args = attribute_list.items[i*column_height+c] # [c*columns+i]
          next if args.nil?
          label, value = if args[0] == :custom
                           attribute_item(*args[1])
                         elsif args[0] == :attribute
                           attribute_item(record, *args[1])
                         end
          line << content_tag(:td, label, :class=>:label) << content_tag(:td, value, :class=>:value)
        end
        code << content_tag(:tr, line.html_safe)
      end
      code = content_tag(:table, code.html_safe, :class=>"attributes-list")
    end
    return code.html_safe
  end

  class AttributesList
    attr_reader :items
    def initialize()
      @items = []
    end

    def attribute(*args)
      @items << [:attribute, args]
    end

    def custom(*args)
      @items << [:custom, args]
    end

  end    





  # TOOLBAR

  def menu_to(name, url, options={})
    raise ArgumentError.new("##{__method__} cannot use blocks") if block_given?
    icon = (options.has_key?(:menu) ? options.delete(:menu) : url.is_a?(Hash) ? url[:action] : nil)
    sprite = options.delete(:sprite) || "icons-16"
    options[:class] = (options[:class].blank? ? 'mn' : options[:class]+' mn')
    options[:class] += ' '+icon.to_s if icon
    link_to(url, options) do
      (icon ? content_tag(:span, '', :class=>"icon")+content_tag(:span, name, :class=>"text") : content_tag(:span, name, :class=>"text"))
    end
  end


  def tool_to(name, url, options={})
    raise ArgumentError.new("##{__method__} cannot use blocks") if block_given?
    icon = (options.has_key?(:tool) ? options.delete(:tool) : url.is_a?(Hash) ? url[:action] : nil)
    sprite = options.delete(:sprite) || "icons-16"
    options[:class] = (options[:class].blank? ? 'btn' : options[:class]+' btn')
    options[:class] += ' '+icon.to_s if icon
    link_to(url, options) do
      (icon ? content_tag(:span, '', :class=>"icon")+content_tag(:span, name, :class=>"text") : content_tag(:span, name, :class=>"text"))
    end
  end

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
          args[0] = ::I18n.t("actions.#{args[1][:controller]||controller_name}.#{name}".to_sym, {:default=>["labels.#{name}".to_sym]}.merge(args[2].delete(:i18n)||{})) if name.is_a? Symbol
          if name.is_a? Symbol and name!=:back
            args[1][:action] ||= name
          end
          code << tool_to(*args) if authorized?(args[1])
        elsif nature == :print
          dn, args, url = tool[1], tool[2], tool[3]
          url[:controller] ||= controller_name
          for dt in @current_company.document_templates.find(:all, :conditions=>{:nature=>dn.to_s, :active=>true}, :order=>:name)
            code << tool_to(tc(:print_with_template, :name=>dt.name), url.merge(:template=>dt.code), :tool=>:print) if authorized?(url)
          end
        elsif nature == :mail
          args[2] ||= {}
          email_address = ERB::Util.html_escape(args[0])
          extras = %w{ cc bcc body subject }.map { |item|
            option = args[2].delete(item) || next
            "#{item}=#{Rack::Utils.escape(option).gsub("+", "%20")}"
          }.compact
          extras = extras.empty? ? '' : '?' + ERB::Util.html_escape(extras.join('&'))
          # code << content_tag(:div, mail_to(*args), :class=>:tool)
          code << tool_to(args[1], "mailto:#{email_address}#{extras}".html_safe, :tool=>:mail)
        elsif nature == :missing
          action, record, tag_options = tool[1], tool[2], tool[3]
          tag_options = {} unless tag_options.is_a? Hash
          url = {}
          url.update(tag_options.delete(:params)) if tag_options[:params].is_a? Hash
          url[:controller] ||= record.class.name.underscore.pluralize # controller_name
          url[:action] = action
          url[:id] = record.id
          code << tool_to(t("actions.#{url[:controller]}.#{action}", record.attributes.symbolize_keys), url, tag_options) if authorized?(url)
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
    
    def print(*args)
      # TODO reactive print
      # @tools << [:print, args]
    end

    #     def update(record, url={})
    #       @tools << [:update, record, url]
    #     end

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

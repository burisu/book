# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper



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


  def confirm(operation)
    sentence  = 'Êtes-vous '
    sentence += case @current_person.sex
                when 'f': 'sûre'
                when 'h': 'sûr'
                else 'sûr(e)'
                end
    sentence += case operation
                when :delete
                  ' de vouloir supprimer cet enregistrement'
                else
                  ''
                end
    sentence += ' ?'
    sentence
  end

  
  def operation(object, operation, controller_path=self.controller.controller_path)
    return "" if not operation[:condition].nil? and operation[:condition]==false
    code = ""
    operation[:action] = operation[:actions][object.send(operation[:use]).to_s] if operation[:use]
    parameters = {}
    parameters[:confirm] = I18n.translate(operation[:confirm]) unless operation[:confirm].nil?
    parameters[:method]  = operation[:method]    unless operation[:method].nil?
    parameters[:id]      = operation[:action].to_s+"-"+(object.nil? ? 0 : object.id).to_s
    
    image_title = I18n.t(operation[:title].nil? ? operation[:action].to_s.humanize : operation[:title])
    dir = "#{RAILS_ROOT}/public/images/"
    image_file = "buttons/"+(operation[:image].nil? ? operation[:action].to_s.gsub(operation[:prefix].to_s||"","") : operation[:image].to_s)+".png"
    image_file = "buttons/unknown.png" unless File.file? dir+image_file
    code += link_to image_tag(image_file, :border => 0, :alt=>image_title, :title=>image_title), {:action => operation[:action].to_s, :id => object.id}, parameters
    code
  end

  def value_image(value)
    unless value.nil?
      image = nil
      case value.to_s
        when "true" : image = "true"
        when "false" : image = nil
        else image =  value.to_s
      end
#      "<div align=\"center\">"+image_tag("buttons/"+image+".png", :border => 0, :alt=>image.t, :title=>image.t)+"</div>" unless image.nil?
      image_tag("buttons/"+image+".png", :border => 0, :alt=>image.t, :title=>image.t) unless image.nil?
    end
  end
  
  
  ENTITIES = {'(C)'=>'&copy;', '(R)'=>'&reg;', '(TM)'=>'<sup>TM</sup>', '(tm)'=>'<sup>tm</sup>','~'=>'&sim;', '->'=>'&rarr;', '<-'=>'&larr;', '<->'=>'&harr;', '=>'=>'&rArr;', '<='=>'&lArr;', '>>'=>'&raquo;', '<<'=>'&laquo;', '...'=>'&hellip;'}
  ALIGNS = {'  '=>'center', ' x'=>'right', 'x '=>'left', 'xx'=>''}

  def dokuwikize(text)
    content = text.dup.to_s
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

    content.gsub!(/\{\{\ *(\w*)\ *(\|[^\}]+)?\}\}/) do |data|
      data = data.squeeze(' ')[2..-3].split('|')
      align = ALIGNS[(data[0][0..0]+data[0][-1..-1]).gsub(/[^\ ]/,'x')]
      image = Image.find_by_name(data[0].strip)
      title = data[1]
      if image.nil?
        "**<span class=\"e\">Image introuvable (#{data})</span>**"
      else
        title ||= image.title
        code  = '<img class="media'+align+'"'
        code += ' align="'+align+'"' if ['left', 'right'].include? align
        code += ' alt="'+title+'" title="'+title+'"' if title
        code += ' src="'+ActionController::Base.relative_url_root.to_s+'/'+image.document_options[:base_url]+'/'+image.document_relative_path('thumb')+'"/>'
        code = link_to(code, {:controller=>:intra, :action=>:image_detail, :id=>image.id}, {:class=>:media})
        #code  = '<a class="media" title="'+image[:document]+'" href="'+url_for(:controller=>:intra, :action=>:image_detail, :id=>image.id)+'">'+code+'</a>'
        # code  = ' '+code+' '
        # code += "@"+data[0].gsub(' ','_')+'@'+(data[0][0..0]+data[0][-1..-1]).gsub(' ','_')+"@"
        code
      end
    end

    for x in 2..5
      n = 7-x
      content.gsub!(/^\s*\={#{n}}([^\=]+)\={#{n}}\s*$/, "<h#{x}>\\1</h#{x}>")
    end

    content.gsub!(/^\ \ (.*)$/, '  <pre>\1</pre>')
    content.gsub!("</pre>\n  <pre>", "\n  ")

    content.gsub!(/\!([^\!]+)\!/, '**\1**')
    content.gsub!(/(^|[^\*])\*([^\*]|$)/, '\1&lowast;\2')
    content.gsub!(/\*\*([^\s][^\*]+)\*\*/, '<strong>\1</strong>')
    content.gsub!(/([^\:])\/\/([^\s][^\/]+)\/\//, '\1<em>\2</em>')
    content.gsub!(/\'\'([^\s][^\']+)\'\'/, '<code>\1</code>')
    content.gsub!(/\_\_([^\s][^\_]+)\_\_/, '<span class="u">\1</span>')
    content.gsub!(/(^)([^\s][^\s].*)($)/, '<p>\2</p>')
    content.gsub!("</p>\n<p>", "\n")
    content
  end
  





  
  
  def print_table (table,options={:label=>nil, :records=>nil, :style=>''}, &block)
    records = options[:records].nil? ? instance_variable_get("@#{table.to_s}") : options[:records]
    record_pages = instance_variable_get("@#{table.to_s.singularize.to_s}_pages") if record_pages.nil?
    model  = table.to_s.singularize.camelize.constantize
    definition = OutputTableDefinition.new(model)
    yield definition
    # Procedures    
    process = ''
    if definition.procedures.size>0
      for proc in 0..(definition.procedures.size-1)
        process += ' &nbsp;&bull;&nbsp; ' if proc>0
        process += link_to(definition.procedures[proc][0], definition.procedures[proc][1]) 
      end
      process = content_tag('div',process,:class=>"menu")
    end
    code = ''
    if records and records.size>0
      line = ''
      for column in definition.columns
        case column.nature
          when :datum  : line += content_tag('th', h(column.header))
          when :action : line += content_tag('th', column.header, :class=>"act")
        end
      end
      code  = content_tag('tr',line)
      for record in records
        line = ''
        for column in definition.columns
          case column.nature
            when :datum  :
              style = options[:style]
              css_class = ''
              datum = column.data(record)
              if column.datatype==:boolean
                datum = value_image(datum)
                style='text-align:center;'
              end
              datum = link_to datum, url_for(column.url(record)) if column.is_linkable?
              if column.options[:mode]==:download and !datum.nil?
                datum = link_to(value_image('download'), url_for_file_column(record, column.options[:name])) 
                style='text-align:center;'
                css_class = ' act'
              end
              if column.options[:name]==:color
                style='text-align:center; width:6ex; border:1px solid black; background: #'+datum+'; color:#'+viewable(datum)+';'
              end
              line += content_tag('td', datum, :class=>column.datatype.to_s+css_class, :style=>style)
#              case column.datatype
#                when :date    : line += content_tag('td', , :align=>"center")
#                when :decimal : line += content_tag('td', column.data(record), :align=>"right")
#                when :integer : line += content_tag('td', column.data(record), :align=>"right")
#                when :float   : line += content_tag('td', column.data(record), :align=>"right")
#                when :boolean : line += content_tag('td', value_image(column.data(record)), :align=>"center")
#                else line += content_tag('td', h(column.data(record)))
#              end
            when :action : line += content_tag('td', column.valids_condition(record) ? operation(record, column.options) : "" , :class=>"act") 
            else line += content_tag('td','&nbsp;&empty;&nbsp;')
          end
        end
        code += content_tag('tr',line, :class=>cycle('odd','even'))
      end
    else
      code += content_tag(:tr,content_tag(:td, I18n.t("app.no_records"), :colspan=>definition.columns.size, :class=>"norecord"))
    end
    line = ''
    if record_pages
      line += link_to('Previous page'.t, { :page => record_pages.current.previous }) if record_pages.current.previous
      if record_pages.current.next
        line += ' &bull; ' if line.size>0
        line += link_to('Next page'.t, { :page => record_pages.current.next })
      end
    end
    code += content_tag('tr',content_tag('td',line, :colspan=>definition.columns.size, :class=>"navigation")) if line.size>0
    code = process+content_tag('table', code, :class=>"list")
    code = content_tag('div', code)
    code = content_tag('h3',  h(options[:label])) + code unless options[:label].nil?
    code = content_tag('div', code)
    code = content_tag('div', code, :class=>"futo")
    code = content_tag('h2', options[:title], :class=>"futo") + code unless options[:title].nil?
    code
  end

  
  
  
end












  class OutputTableColumn
     attr_reader :nature, :options
    def initialize(model, nature=:data, options={:name=>nil, :type=>:string})
      @model           = model
      @nature          = nature
      @options         = options
      if @options[:through].is_a? Array
        if @options[:through].size==1
          @options[:through] = @options[:through][0]
        end
      end
    end
    
    def header
      if @options[:label]
        @options[:label].to_s
      else
        case @nature
          when :datum :
            if @options[:through] and @options[:through].is_a?(Symbol)
#              @model.reflections[@options[:through]].class_name.constantize.localized_model_name
              raise Exception.new("Unknown reflection :#{@options[:through].to_s} for the ActiveRecord: "+@model.to_s) if @model.reflections[@options[:through]].nil?
              @model.columns_hash[@model.reflections[@options[:through]].primary_key_name].human_name
            elsif @options[:through] and @options[:through].is_a?(Array)
              model = @model
              for x in 0..@options[:through].size-2
                model = model.reflections[@options[:through][x]].options[:class_name].constantize
              end
              reflection = @options[:through][@options[:through].size-1].to_sym
              model.columns_hash[model.reflections[reflection].primary_key_name].human_name
            else
#              raise Exception.new("Unknown property :#{@options[:name].to_s} for the ActiveRecord: "+@model.to_s) if @model.columns_hash[@options[:name].to_s].nil?
#              @model.human_attribute_name(@options[:name].to_sym)
#              @model.human_attribute_name(@options[:name].to_sym)
              I18n.translate("activerecord.attributes.#{@model.to_s.singularize.underscore}.#{@options[:name].to_s}")
            end;
          when :action : 'ƒ'
          else '-'
        end
      end
    end
    
    def data(record)
      if @options[:through]
        if @options[:through].is_a?(Array)
          r = record
          for x in 0..@options[:through].size-1
            r = r.send(@options[:through][x])
          end
          r.nil? ? nil : r.send(@options[:name])
        else
          r = record.send(@options[:through])
          r.nil? ? nil : r.send(@options[:name])
        end
      else
        record.send(@options[:name])
      end
    end
    
    def is_linkable?
      @options[:url]
    end
    
    def url(record)
      @options[:url][:id]= get_record(record).id unless @options[:id] and @options[:id]==:none
      @options[:url]
    end
    
    def datatype
      @model.columns_hash[@options[:name].to_s].send(:type)
    end
    
    def valids_condition(record)
      condition = @options[:condition]
      if condition
        cond = condition.to_s
        if cond.match /^not__/
          !record.send(cond[5..255])
        else
          record.send(cond)
        end
      else
        true
      end
    end
    
    private
    
    def get_record(record)
      if @options[:through]
        if @options[:through].is_a?(Array)
          r = record
          for x in 0..@options[:through].size-1
            r = r.send(@options[:through][x])
          end
          r
        else
          record.send(@options[:through])
        end
      else
        record
      end
    end
    
  end

  class OutputTableDefinition
    attr_reader :columns, :data_count, :link_count, :model, :procedures

    def initialize(model)
      @model = model
      @columns = []
      @procedures = []
      @data_count = 0
      @link_count = 0
    end

    def datum(name,options={:type=>:string})
      options[:name] = name
      @columns << OutputTableColumn.new(@model, :datum, options)
      @data_count += 1      
    end

    def procedure(name,url={})
      @procedures << [name,url]
    end

    def action(options)
      if options.is_a? Hash
        @columns << OutputTableColumn.new(@model, :action, options)
        @link_count += 1      
      elsif options.is_a? Symbol
        case options
          when :none    :
          when :default :
            @columns << OutputTableColumn.new(@model, :action, {:action=>:show})
            @columns << OutputTableColumn.new(@model, :action, {:action=>:edit})
            @columns << OutputTableColumn.new(@model, :action, {:action=>:destroy, :method=>:post, :confirm=>'Are you sure?'})
            @link_count += 3
          when :show    :
            @columns << OutputTableColumn.new(@model, :action, {:action=>:show})
            @link_count += 1
          when :edit    :
            @columns << OutputTableColumn.new(@model, :action, {:action=>:edit})
            @link_count += 1
          when :destroy :
            @columns << OutputTableColumn.new(@model, :action, {:action=>:destroy, :method=>:post, :confirm=>'Are you sure?'})
            @link_count += 1
          else
            @columns << OutputTableColumn.new(@model, :action, {:action=>:options})
            @link_count += 1
        end
      end
    end

  end
  









module ActionView
  module Helpers #:nodoc:
    # The TextHelper module provides a set of methods for filtering, formatting
    # and transforming strings, which can reduce the amount of inline Ruby code in
    # your views. These helper methods extend ActionView making them callable
    # within your template files.
    module TextHelper
      begin
        require_library_or_gem "redcloth" unless Object.const_defined?(:RedCloth)
        def textilize(text, *rules)
          if text.blank?
            ""
          else
            rc = RedCloth.new(text, rules)
            rc.no_span_caps = true
            rc.to_html
          end
        end
      rescue LoadError
        # We can't really help what's not there
      end
    end
  end
end




module RotexActiveRecord #:nodoc:
  def self.included(base) #:nodoc:
    base.extend(ClassMethods)
  end

  module ClassMethods

    def list_column(column, reference)
      code = ''
      col = column.to_s
      if reference.is_a? Hash
        reflist = "#{col}_keys".upcase
        code += "#{reflist} = {"+reference.collect{|x| ":"+x[0].to_s+"=>\""+x[1].to_s+"\""}.join(",")+"}\n"
      else
        reflist = reference.to_s
      end
      code << <<-"end_eval"
        def #{col}_include?(key)
          raise(Exception.new("Only Symbol are accepted")) unless key.is_a?(Symbol)
          return false unless #{reflist}.include?(key)
          return !self.#{col}.to_s.match("(\ |^)"+key.to_s+"(\ |$)").nil?
        end
        def #{col}_add(key)
          raise(Exception.new("Only Symbol are accepted")) unless key.is_a?(Symbol)
          return self.#{col} unless #{reflist}.include?(key)
          self.#{col} = self.class.#{col}_string(self.#{col}_array << key)
        end
        def #{col}_remove(key)
          raise(Exception.new("Only Symbol are accepted")) unless key.is_a?(Symbol)
          return self.#{col} unless #{reflist}.include?(key)
          array = self.#{col}_array
          array.delete(key)
          self.#{col} = self.class.#{col}_string(array)
        end
        def #{col}_set(key, add = true)
          if add
            return #{col}_add(key)
          else
            return #{col}_remove(key)
          end 
        end
        def #{col}_array
          self.#{col}.to_s.split(" ").collect{|key| key.to_sym if #{reflist}.include?(key.to_sym)}.compact
        end
        def self.#{col}_string(array=nil)
          array = self.#{col}_array if array.nil?
          " "+array.flatten.uniq.sort{|x,y| x.to_s<=>y.to_s}.join(" ")+" "
        end
        def #{col}_string
          self.class.#{col}_string(self.#{col}_array)
        end
      end_eval
#      ActionController::Base.logger.error(code)
      module_eval(code)
    end
    
  end
end

ActiveRecord::Base.send(:include, RotexActiveRecord)


if defined? Encoding
  Encoding.default_internal = Encoding::UTF_8
  Encoding.default_external = Encoding::UTF_8
end

module Book
  module I18n

    module ContextualModelHelpers
      
      def tl(*args)
        args[0] = 'models.'+self.name.underscore+'.'+args[0].to_s
        ::I18n.translate(*args)
      end
      alias :tc :tl

      def tg(*args)
        args[0] = 'labels.'+args[0].to_s
        ::I18n.translate(*args)
      end

    end

    module ContextualModelInstanceHelpers
      
      def tl(*args)
        args[0] = 'models.'+self.class.name.underscore+'.'+args[0].to_s
        ::I18n.translate(*args)
      end
      alias :tc :tl

      def tg(*args)
        args[0] = 'labels.'+args[0].to_s
        ::I18n.translate(*args)
      end

    end

    module ContextualHelpers

      #       def tc(*args)
      #         args[0] = contextual_scope+'.'+args[0].to_s
      #         for i in 1..args.size
      #           args[i] = ::I18n.localize(args[i]) if args[i].is_a? Date
      #         end if args.size > 1
      #         ::I18n.translate(*args)
      #       end

      #       def tg(*args)
      #         args[0] = 'general.'+args[0].to_s
      #         ::I18n.translate(*args)
      #       end

      def tl(*args)
        args[0] = 'labels.'+args[0].to_s
        ::I18n.translate(*args)
      end
      alias :tc :tl
      alias :tg :tl
      
      private

      def contextual_scope
        app_dirs = '(helpers|controllers|views|models)'
        latest_app_file = caller.detect { |level| level =~ /.*\/app\/#{app_dirs}\/[^\.\.]/ }
        return 'eval' unless latest_app_file
        latest_app_file.split(/\/app\//)[1].split(/\./)[0].gsub('/','.').gsub(/(_controller$|_helper$|_observer$)/,'')
      end

    end

  end
end

ActionController::Base.send :extend, Book::I18n::ContextualHelpers
ActionController::Base.send :include, Book::I18n::ContextualHelpers
ActiveRecord::Base.send :extend, Book::I18n::ContextualModelHelpers
ActiveRecord::Base.send :include, Book::I18n::ContextualModelInstanceHelpers
ActionView::Base.send :include, Book::I18n::ContextualHelpers

module ::I18n

  def self.valid_locales
    return [:fra, :eng, :spa, :jpn, :arb] # , :spa, :jpn, :arb
    # FIXME Call to active_locales fails during migrate
    self.available_locales.select{|x| x.to_s.size == 3}
  end

  def self.active_locales
    @@active_locales ||= self.valid_locales
    @@active_locales
  end

  def self.active_locales=(array=[])
    @@active_locales ||= self.valid_locales
    @@active_locales = array unless array.empty?
  end

  def self.locale_label(locale=nil)
    locale ||= self.locale
    "#{locale} ("+self.locale_name+")"
  end

  def self.locale_name(locale=nil)
    locale ||= self.locale
    ::I18n.t("i18n.name")
  end

  # Returns translation if found else nil
  def self.hardtranslate(*args)
    result = translate(*args)
    return (result.to_s.match(/(translation\ missing|\(\(\()/) ? nil : result)
  end

  module Backend
    module Base


      def localize_with_numbers(locale, object, format = :default, options = {})
        options.symbolize_keys!
        if object.respond_to?(:abs)
          if currency = options[:currency]
            return Numisma[currency].localize(object, :locale=>locale)
          else
            formatter = I18n.translate('number.format'.to_sym, :locale => locale, :default => {})
            if formatter.is_a?(Proc)
              return formatter[object]
            elsif formatter.is_a?(Hash)
              formatter = {:format => "%n", :separator=>'.', :delimiter=>'', :precision=>3}.merge(formatter).merge(options)
              format = formatter[:format]
              negative_format = formatter[:negative_format] || "-" + format

              if object.to_f < 0
                format = negative_format
                object = object.abs
              end
              
              value = object.to_s.split(/\./)
              integrals, decimals = value[0].to_s, value[1].to_s
              decimals = decimals.gsub(/0+$/, '').ljust(formatter[:precision], '0').reverse.split(/(?=\d{3})/).reverse.collect{|x| x.reverse}.join(formatter[:delimiter])
              value = integrals.gsub(/^0+[1-9]+/, '').gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{formatter[:delimiter]}")
              value += formatter[:separator] + decimals unless decimals.blank?
              return format.gsub(/%n/, value).gsub(/%s/, "\u{00A0}").html_safe
            end
          end
        elsif object.respond_to?(:strftime)
          return localize_without_numbers(locale, object, format, options)
        else
          raise ArgumentError, "Object must be a Numeric, Date, DateTime or Time object. #{object.inspect} given."
        end
      end
      alias_method_chain :localize, :numbers
  

    end
  end

end



module ActiveModel
  class Errors

    #     # allow a proc as a user defined message
    #     def add(attribute, message = nil, options = {})
    #       message ||= :invalid
    #       raise options.inspect if options.frozen?
    
    #       message = generate_message(attribute, message, options) # if message.is_a?(Symbol)
    #       self[attribute] ||= []
    #       self[attribute] << message
    #     end
    

    def add(attribute, message = nil, options = {})
      message ||= :invalid
      
      if message.is_a?(Symbol)
        message = generate_message(attribute, message, options.except(*CALLBACKS_OPTIONS))
      elsif message.is_a?(Proc)
        message = message.call
      elsif !options.delete(:forced)
        raise ArgumentError.new("Symbol or Proc expected, #{message.inspect} received.")
      end
      
      self[attribute] << message
    end




    def add_to_base(message, options = {})
      add(:id, message, options)
    end

    def add_from_record(record)
      record.errors.each do |attribute, message|
        self[attribute] ||= []
        self[attribute] << message
      end
    end

    # Returns all the full error messages in an array.
    #
    #   class Company
    #     validates_presence_of :name, :address, :email
    #     validates_length_of :name, :in => 5..30
    #   end
    #
    #   company = Company.create(:address => '123 First St.')
    #   company.errors.full_messages # =>
    #     ["Name is too short (minimum is 5 characters)", "Name can't be blank", "Address can't be blank"]
    def full_messages(options = {})
      full_messages = []
      each do |attribute, messages|
        messages = Array.wrap(messages)
        full_messages += messages
      end
      full_messages
    end 

  end
end



ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  msg = instance.error_message
  error_class = 'invalid'
  
  if html_tag =~ /<(input|textarea|select)[^>]+class=/
    class_attribute = html_tag =~ /class=['"]/
    html_tag.insert(class_attribute + 7, "#{error_class} ")
  elsif html_tag =~ /<(input|textarea|select)/
    first_whitespace = html_tag =~ /\s/
    html_tag[first_whitespace] = " class=\"#{error_class}\" "
  end
  
  html_tag
end

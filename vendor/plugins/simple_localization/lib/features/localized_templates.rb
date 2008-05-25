# = Localized templates
# 
# This feature extends Rails template handling and allows the use of localized
# templates like <code>index.de.rhtml</code>. The plugin will then pick the
# template matching the currently used language
# (<code>Language#current_language</code>).
# 
# The code for this feature is taken from the Globalize plugin for Rails
# (http://www.globalize-rails.org/) and is slighly modified to avoid naming
# conflicts. The Globalize team deserves all credit for this great solution.
# If you find this feature helpful thank them.
# 
# == Used sections of the language file
# 
# This feature does not use sections from the lanuage file.

module ArkanisDevelopment::SimpleLocalization #:nodoc:
  module LocalizedTemplates
    
    def self.included(base)
      base.class_eval do
        
        alias_method :render_file_without_localization, :render_file
        
        # Name of file extensions which are handled internally in rails. Other types
        # like liquid has to register through register_handler.
        # The erb extension is used to handle .html.erb templates.
        @@native_extensions = /\.(rjs|rhtml|rxml|erb)$/
        
        @@localized_path_cache = {}
    
        def render_file(template_path, use_full_path = true, local_assigns = {})
          @first_render ||= template_path
          
          localized_path = locate_localized_path(template_path, use_full_path)
          # don't use_full_path -- we've already expanded the path
          render_file_without_localization(localized_path, false, local_assigns)
        end
        
        private
        
        alias_method :path_and_extension_without_localization, :path_and_extension
        
        # Override because the original version is too minimalist
        def path_and_extension(template_path) #:nodoc:
          template_path_without_extension = template_path.sub(@@native_extensions, '')
          [ template_path_without_extension, $1 ]
        end
        
        def locate_localized_path(template_path, use_full_path)
          current_language = Language.current_language
          
          cache_key = "#{current_language}:#{template_path}"
          cached = @@localized_path_cache[cache_key]
          return cached if cached
          
          if use_full_path
            template_path_without_extension, template_extension = path_and_extension(template_path)
            
            if template_extension
              template_file_name = full_template_path(template_path_without_extension, template_extension)
            else
              template_extension = pick_template_extension(template_path).to_s
              template_file_name = full_template_path(template_path, template_extension)
            end
          else
            template_file_name = template_path
            #raise [template_path, path_and_extension(template_path)].inspect
            template_extension = path_and_extension(template_path).last
          end
          
          pn = Pathname.new(template_file_name)
          dir, filename = pn.dirname, pn.basename('.' + template_extension.to_s)
          
          localized_path = dir + "#{filename}.#{current_language}.#{template_extension.to_s}"
          
          unless localized_path.exist?
            localized_path = template_file_name
          end
          
          @@localized_path_cache[cache_key] = localized_path.to_s
        end
        
      end
    end
    
  end
end

ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedTemplates

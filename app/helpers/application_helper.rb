# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
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




# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_deliveries = true
config.action_mailer.delivery_method = :smtp
config.action_mailer.default_charset = "utf-8"
# raise Exception.new RUBY_VERSION.inspect
if RUBY_VERSION > "1.8.6"
  config.action_mailer.smtp_settings = {:address => "mail.gandi.net", :port => 587, :domain=>'rotex1690.org', :user_name=>'postmaster@rotex1690.org', :password=>'r0T3X1690',  :authentication=>:plain, :enable_starttls_auto => true}
else
  config.action_mailer.smtp_settings = {:address => "mail.gandi.net", :port => 587, :domain=>'rotex1690.org', :user_name=>'postmaster@rotex1690.org', :password=>'r0T3X1690',  :authentication=>:login, :tls=>true}
end
#config.action_mailer.smtp_settings = {:address => "localhost", :port => 25, :domain=>'oneiros.fr' }

recaptcha_file = Rails.root.join("config", "recaptcha.yml")
if File.exist?(recaptcha_file)
  conf = YAML.load_file(recaptcha_file)
  Recaptcha.configure do |config|
    for key, value in conf
      config.send("#{key}=", value)
    end
  end
end



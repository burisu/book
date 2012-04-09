module ApplicationHelper
  # Fournit la liste des pays
  def countries
    I18n.translate(:countries).collect{|k,v| [v, k]}
  end

  def back_url
    :back
  end

end


class ::String
	Majuscules = ['À','Â','Ä','É','È','Ê','Ë','Ì','Ï','Î','Ò','Ô','Ö','Û','Ü','Ù','Ç']
	Minuscules = ['à','â','ä','é','è','ê','ë','ì','ï','î','ò','ô','ö','û','ü','ù','ç']
	Moluscules = ['a','a','a','é','é','é','é','i','i','i','o','o','o','u','u','u','ss'] # Phonétique
	Meruscules = ['a','a','a','e','e','e','e','i','i','i','o','o','o','u','u','u','c']  # Simplification

  def lower
		ss = self.dup.to_s
		m = Majuscules.length-1
		for x in 0..m
			ss.gsub!(Majuscules[x],Minuscules[x])
		end
    return ss.downcase
  end

  def upper
		ss = self.dup.to_s
		m = Majuscules.length-1
		for x in 0..m
			ss.gsub!(Minuscules[x],Majuscules[x])
		end
    return ss.upcase
  end

  def up_ss
		ss = self.dup.to_s
		m = Majuscules.length-1
		for x in 0..m
			ss.gsub!(Minuscules[x],Meruscules[x])
			ss.gsub!(Majuscules[x],Meruscules[x])
		end
    return ss.upcase
  end

	def to_ss
		ss = self.dup.to_s
		ss.downcase!
		ss.strip!
		ss.gsub!('@',' arobase ')
		ss.gsub!('€',' euro ')
		ss.gsub!('$',' dollar ')
		ss.gsub!('£',' livre ')
		ss.gsub!('%',' pourcent ')
		ss.gsub!('★',' étoile ')
		ss.gsub!(/(–|-)/,' tiret ')

		m = Majuscules.length-1
		for x in 0..m
			ss.gsub!(Majuscules[x],Moluscules[x])
			ss.gsub!(Minuscules[x],Moluscules[x])
		end
		ss += ' '
		ss.gsub!('.',' . ')
		ss.gsub!(/\'/,' ')
    ss.gsub!(/(\\|\/|\-|\_|\&|\||\,|\.|\!|\?|\*|\+|\=|\(|\)|\[|\]|\{|\}|\$|\#)/, " ")


		# Analyse phonétique
    ss.gsub!("y", "i")
    ss.gsub!(/(a|e|é|i|o|u)s(a|e|é|i|o|u)/, '\1z\2')
    ss.gsub!(/oi/, 'oa')
    ss.gsub!(/ii/,  "ie")
    ss.gsub!(/ess/, 'és')

		ss.squeeze! "a-z"
    ss.gsub!(/(^| )ou(a|e|i|o|u)/, '\1w\2')
    ss.gsub!(/ph/, 'f')
    ss.gsub!(/ou/, 'u')
    ss.gsub!(/oe/, 'e')
    ss.gsub!(/(.)ent( |$)/, '\1e\2')
    ss.gsub!(/eu(s|x)?/, 'e')
    ss.gsub!(/(ai|ei)n/,  "in")
    ss.gsub!(/(i|u|y)e(\ |$)/, '\1 ')
    ss.gsub!(/(e|a)i/, "é")
    ss.gsub!(/est( |$)/, 'é\1')
    ss.gsub!(/(e)?au/, 'o')

    ss.gsub!(/(l|k)s( |$)/, '\1')
    ss.gsub!(/(e|é)(r|t|s)s? /, "é ")
    ss.gsub!(/c(é|e|i)/, 's\1')
    ss.gsub!(/g(é|e|i)/, 'j\1')
    ss.gsub!(/e(m|n)/, 'an')
    ss.gsub!("gu", "g")
    ss.gsub!(/(c|q)/, 'k')
    ss.gsub!(/ku([aeiou])/, 'k\1')
    ss.gsub!("mn", "m")
    ss.gsub!(/(g|k)n/, 'n')
    ss.gsub!(/(m|n|r)(t|d|p|q|k)?s?( |$)/, '\1\3')
    ss.gsub!(/(.)t( |$)/, '\1\2')
    ss.gsub!(/ati/, "asi")
    ss.gsub!("tion", "sion")
    ss.gsub!(/(e|i|u|o|a)(s|x) /, '\1 ')

    ss.gsub!(/é/, 'e')
		ss.squeeze! "a-z"
    ss.gsub!("skh", "sh")
    ss.gsub!("kh", "sh")
    ss.gsub!("sh", "@")
    ss.gsub!("h", "")
    ss.gsub!("@", "sh")
    ss.gsub!(/[^a-z0-9]/,' ')
		ss.squeeze! " "
		ss.strip!
		return ss
	end

  def soundex2
    word = self.dup
    steps = ":"#+word+"/"
    word = word.strip.downcase
    word.delete!("\\ -_&|,.!?%$*+=()[]{}#")
    word.tr!("^bcdfghjklmnpqrstvwxz","a")
    steps += word +" / "
#    word.gsub!(/gui/,"ki")
#    word.gsub!(/gue/,"ke")
    word.gsub!(/ga/,"ka")
#    word.gsub!(/go/,"ko")
    word.gsub!(/gu/,"k")
    word.gsub!(/ca/,"ka")
#    word.gsub!(/co/,"ko")
#    word.gsub!(/cu/,"ku")
    word.gsub!(/q/,"k")
    word.gsub!(/cc/,"k")
    word.gsub!(/ck/,"k")
    steps += word +" / "
    word.tr!("eiou","a") if word[0]!="a"
    steps += word +" / "
    word.gsub!(/mac/,"mcc")
    word.gsub!(/asa/,"aza")
    word.gsub!(/kn/,"nn")
    word.gsub!(/pf/,"ff")
    word.gsub!(/sch/,"sss")
    word.gsub!(/ph/,"ff")
    steps += word +" / "
    word.gsub!(/ch/,"ç")
    word.gsub!(/sh/,"@")
    word.delete!("h")
    word.gsub!(/ç/,"ch")
    word.gsub!(/@/,"sh")
    steps += word +" / "
#    word.gsub!(/ay/,"ç")
#    word.delete!("h")
#    word.gsub!(/ç/,"ay")
    steps += word +" / "
    word.gsub!(/[atds]$/,"")
    steps += word +" / "
    word[0]="@" if word[0]=="a"
    word.gsub!(/a/,"")
    word.gsub!(/@/,"a")
    steps += word +" / "
    word.squeeze!
    steps += word +" / "
    word[0..3].strip.upcase.ljust(4," ")#+":: "+steps.dump
  end

  begin
    require_library_or_gem "redcloth" unless Object.const_defined?(:RedCloth)

    def textilize(*rules)
      self.blank? ? "" : RedCloth.new(self, rules).to_html
    end

  rescue LoadError
      # We can't really help what's not there
  end

  
end

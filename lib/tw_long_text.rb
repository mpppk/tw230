require 'addressable/uri'

class TwLongText
  MAX_URL_LENGTH        = 37
  NORMALIZED_URL_LENGTH = 23

  def initialize text
    @text = text
  end

  # 日本語URLにすべき状態になっているか
  def valid_url? text
    puts "#{text} is long then MAX_URL_LENGTH"; return false if text.length > (MAX_URL_LENGTH + 1)
    puts "#{text} don't have dot"; return false if text.index(".") == nil
    puts "#{text} is short then NORMALIZED_URL_LENGTH"; return false if text.length < NORMALIZED_URL_LENGTH
    true
  end

  # 正しい変換後のURLになっているか
  def normalized_url? text
    return false if text.index("http") == nil
    true
  end

  # 受け取った文字列が141文字以上ならURLに変換
  def to_short_text
  	urls = add_dot(divide @text)
  	normalized_urls = urls.map do |url|
  		if valid_url?(url) then normalize_url("http://#{url}")
      else url end
  	end
  	normalized_urls.join(" ")
  end

  # 文章を37文字ごとに区切る
  def divide text
    text.split("").each_slice(MAX_URL_LENGTH).to_a.map{|t| t.join}
  end
  private :divide
  
  # 24文字以上の文字列要素には、２文字目にドットを挿入する
  def add_dot texts
  	texts.map do |t|
  		if t.length > 23 then t.insert(1, ".")
  		else t end
  	end
  end
  private :add_dot

  # 日本語URLを読み込み可能な形に変更する
  def normalize_url url
  	url = Addressable::URI.parse(url)
  	url.normalize.to_s
  end
  private :normalize_url

end
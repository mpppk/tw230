require 'addressable/uri'
require 'uri'

class TwLongText
  MAX_URL_LENGTH            = 37
  NORMALIZED_URL_LENGTH     = 23
  MAX_NORMALIZED_URL_LENGTH = 63

  def initialize text
    @text = prepare_text text
  end

  def prepare_text text
    puts "---- original text ----"
    puts text
    text = divide_link text
    puts "linnks in prepare_text: #{@links}"
    text.gsub!("　", " ")        # => 全角空白を半角空白に置換
    text.gsub!(/^ +/, "")        # => 文頭の空白を削除
    text.gsub!(/ +$/, "")        # => 文末の空白を削除
    text.gsub!(/ +/, " ")        # => 繰り返す空白を削除
    text.gsub!(/[、。，]/, ".")   # => 句読点をドットに変換
    text.gsub!(/[ _\-\.\$]+$/, "")    # => 文末の記号を削除  
    text.gsub!(/ /, "_")         # => 空白を_に置換  
    
    # URLに使えない記号を取り除く
    text.scan(URI::UNSAFE).join.scan(/[^\p{Hiragana}\p{Katakana}一-龠々ー]/).each do |c|
      text.gsub!(c.to_s, "")
    end

    # 数字を漢数字に変換する
    text.scan(/[0-9]+/).each do |n|
      text.gsub!(n, num_to_k(n.to_i))
    end

    puts "---- prepared text ----"
    puts text
    text
  end

  # 日本語URLにすべき状態になっているか
  def valid_url? text
    if text.index(".") == nil
      puts "#{text} don't have dot"
      return false 
    end
    if text.length < NORMALIZED_URL_LENGTH
      puts "#{text} is short then NORMALIZED_URL_LENGTH"
      return false
    end
    true
  end

  # 正しい変換後のURLになっているか
  def normalized_url? text
    return false if text.index("http") == nil
    true
  end

  # 受け取った文字列が141文字以上ならURLに変換
  def to_short_text
    puts "links in short text: #{@links}"
    urls = add_dot(divide @text)
    normalized_urls = urls.map do |url|
      if valid_url?(url) then normalize_url("http://#{url}")
      else url end
    end
    short_text = normalized_urls.join(" ")
    @links.each do |link|
      puts "link: #{link}"
      short_text << " #{link}"
    end
    short_text
  end

  # 文章中のURLを文章の最後に持ってくる
  def divide_link text
    new_text = text
    @links = URI.extract(text)
    puts "links in divide_link: #{@links}"
    @links.each{ |link| new_text.gsub!(link, "") }
    new_text
  end

  # 文章を37文字ごとに区切る
  def divide text
    text.split("").each_slice(MAX_URL_LENGTH).to_a.map{|t| t.join}
  end
  private :divide
  
  # 24文字以上の文字列要素には、後ろから２文字目にドットを挿入する
  def add_dot texts
    # 最後の24文字以内にドットが含まれており、かつそのドット以降に数字やアルファベットが入っていない場合は問題無い
  	texts.map do |t|
  		if t.length > NORMALIZED_URL_LENGTH then t.insert(-2, ".")
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

  # 数字を漢数字に変換する
  def num_to_k(n)
    number = 0..9
    kanji = ["","一","二","三","四","五","六","七","八","九"]
    num_kanji = Hash[number.zip(kanji)]
    digit = [1000,100,10]
    # digit = (1..3).map{ |i| 10 ** i }.reverse
    kanji_keta = ["千","百","十"]
    num_kanji_keta = Hash[digit.zip(kanji_keta)]
    num = n
    str = ""
    digit.each { |d|
      tmp = num/d
      str << (tmp == 0 ? "" : ((tmp == 1 ? "" : num_kanji[tmp]) + num_kanji_keta[d]))
      num %= d
    }
    str << num_kanji[num]
    return str
  end
end

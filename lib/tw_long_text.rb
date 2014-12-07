require 'addressable/uri'
require 'uri'

class TwLongText
  MAX_URL_LENGTH            = 38
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

    puts "---- prepared text ----"
    puts text
    text
  end
  private :prepare_text

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
  private :valid_url?

  # 正しい変換後のURLになっているか
  def normalized_url? text
    return false if text.index("http") == nil
    true
  end
  private :normalized_url?

  # 受け取った文字列が141文字以上ならURLに変換
  def to_short_text
    urls = divide(@text)
    normalized_urls = urls.map do |url|
      if valid_url?(url) then normalize_url("http://#{url}")
      else url end
    end
    
    normalized_urls.map do |url|
      url.gsub!("http://.", "http://")
      url.gsub!("https://.", "https://")
    end

    short_text = normalized_urls.join(" ")

    # 文章の末尾がURLでなく、かつ.丨だったら取り除く
    short_text.gsub!(".丨", "")

    @links.each do |link|
      short_text << " #{link}"
    end
    short_text
  end

  # 文章中のURLを文章の最後に持ってくる
  def divide_link text
    new_text = text
    @links = URI.extract(text)
    @links.each{ |link| new_text.gsub!(link, "") }
    new_text
  end
  private :divide_link

  # 文章を37文字ごとに区切る
  def divide text
    texts = []
    que = text.dup.split("")
    
    while que.length > 0
      # 切り出した文字列には、最大で3文字を付与する(.丨)ので、２を引いておく
      slice_length = (que.length >= MAX_URL_LENGTH-3 ) ? MAX_URL_LENGTH-3 : que.length
      pt = add_dot( que.slice!(0, slice_length).join ).split("")
      while que.length > 0 && pt.length < MAX_URL_LENGTH
        break if que[0].match(/[^\p{Hiragana}\p{Katakana}一-龠々ー]/)
        pt << que.shift
      end
      texts << pt.join
    end
    texts
  end
  private :divide
  
  # 24文字以上の文字列要素には、後ろから２文字目にドットを挿入する
  def add_dot text
    # 最後の24文字以内にドットが含まれており、かつそのドット以降に数字やアルファベットが入っていない場合は問題無い
  	bet_dot_texts = text.split(".")

    bet_dot_texts.each do |t|
      next if t.length < (NORMALIZED_URL_LENGTH)
      (t.length/NORMALIZED_URL_LENGTH).floor.times do |i|
        t.insert( (i * NORMALIZED_URL_LENGTH) + (NORMALIZED_URL_LENGTH).to_i, "." )
      end
    end

    # 最後のドット以降に日本語以外が含まれていた場合は、適当なgTLを追加
    bet_dot_texts = bet_dot_texts.join(".").split(".")
    if bet_dot_texts.last.match(/[^\p{Hiragana}\p{Katakana}一-龠々ー]/)
      puts "add .| : #{bet_dot_texts.last}"
      bet_dot_texts.last << ".丨" # 縦棒は漢字のコン
    end

    bet_dot_texts.join(".")
  end
  private :add_dot

  # 日本語URLを読み込み可能な形に変更する
  def normalize_url url
  	url = Addressable::URI.parse(url)
  	url.normalize.to_s
  end
  private :normalize_url
end


# URLにアクセスするためのライブラリを読み込む
require 'open-uri'

# HTMLをパースするためのライブラリを読み込む
require 'nokogiri'

# <td class="date"><span class="yearmonth">2015/10</span> <span class="daydate"> <span class="dd1">19</span> <span class="dd2">Mon</span> </span></td>
# <td class="heading"><span class="author">樋口日奈</span> <span class="entrytitle"><a href="#comments-open" onclick="$('#comments').fadeIn();" style="text-decoration:none;">日だまりのお部屋468 *ひなちま</a></span></td>

# 最強の情報収集術！初心者向けRuby＋NokogiriでWebスクレイピング徹底解説
# http://sideb.hatenablog.com/entry/ruby_scraping_nokogiri

# String 文字列の変換
# http://qiita.com/kidach1/items/7b355eb355b2d1390cf5

# パース対象のHTMLはPC用のものスマホ用URLは利用しない
# PC用
# view-source:http://blog.nogizaka46.com/hina.higuchi/2015/10/025309.php
# スマホ用
# view-source:http://blog.nogizaka46.com/hina.higuchi/smph/2015/10/025309.php

class HTMLParser

  def self.fetch(article_url)
    begin
      parse(article_url, Nokogiri::HTML(open(article_url)))
    rescue OpenURI::HTTPError => ex
      # 無効なURLは処理をせずnilを返却する
      puts "HTTPError : #{ex}"
    end
  end

  private
  def self.parse(article_url, doc)
    # ブログ著者
    # コメント著者のタグ'vcard author'を拾ってしまうのでインデックス0を指定する
    author = doc.css("span.author")[0].inner_html
    # タイトル
    entrytitle = doc.css("span.entrytitle").inner_html
    # 日付
    yearmonth = doc.css("span.yearmonth").inner_html

    dd1 = doc.css("span.dd1").inner_html
    dd2 = doc.css("span.dd2").inner_html
    # 本文
    entrybodyin = doc.css("div.entrybody")

    # RSSのURL(メンバーオブジェクトと紐付けるため)
    rss_url =  doc.css('#rss').css('a')[0][:href]

    # サムネイル画像URLの抽出
    thumbnail_url_arr = Array.new()
    doc.css("div.entrybody").css("img").each do |e|
      thumbnail_url_arr.push(e[:src]) if thumbnail?(e[:src])
    end
    # 拡大画像URLの抽出
    raw_img_url_arr = Array.new()
    doc.css("div.entrybody").css("a").each do |e|
      raw_img_url_arr.push(e[:href]) if raw_image?(e[:href])
    end

    data = {:author => author,
            :entrytitle => entrytitle,
            :yearmonth => yearmonth,
            :dd1 => dd1,
            :dd2 => dd2,
            :entrybodyin => entrybodyin.to_s, # Stringに変換する
            :thumbnail_url_arr => thumbnail_url_arr,
            :raw_img_url_arr => raw_img_url_arr, # already check be enable
            :article_url => article_url,
            :rss_url => rss_url
    }
  end

  # スマホURLパース用
  # 使用しない
  #def self.parse_smph(article_url, doc)
  #  # ブログ著者
  #  # コメント著者のタグ'vcard author'を拾ってしまうのでインデックス0を指定する
  #  author = doc.css("span.author")[0].inner_html
  #  # タイトル
  #  entrytitle = doc.css("span.entrytitle").css("a").inner_html
  #  # 日付
  #  yearmonth = doc.css("span.yearmonth").inner_html
  #  dd1 = doc.css("span.dd1").inner_html
  #  dd2 = doc.css("span.dd2").inner_html
  #  # 本文
  #  entrybodyin = doc.css("div.entrybodyin")
  #  #puts entrybodyin
  #  # サムネイル画像URLの抽出
  #  thumbnail_url_arr = Array.new()
  #  doc.css("div.entrybodyin").css("img").each do |e|
  #    thumbnail_url_arr.push(e[:src]) if thumbnail?(e[:src])
  #  end
  #  # 拡大画像URLの抽出
  #  raw_img_url_arr = Array.new()
  #  doc.css("div.entrybodyin").css("a").each do |e|
  #    raw_img_url_arr.push(e[:href]) if raw_image?(e[:href])
  #  end
  #
  #  data = {:author => author,
  #          :entrytitle => entrytitle,
  #          :yearmonth => yearmonth,
  #          :dd1 => dd1,
  #          :dd2 => dd2,
  #          :entrybodyin => entrybodyin,
  #          :thumbnail_url_arr => thumbnail_url_arr,
  #          :raw_img_url_arr => raw_img_url_arr, # already check be enable
  #          :article_url => article_url
  #  }
  #end

  def self.thumbnail?(url)
    # .gifファイルは無視する
    url.start_with?("http://img.nogizaka46.com/") && !url.end_with?(".gif")
  end

  def self.raw_image?(url)
    url.start_with?("http://dcimg.awalker.jp/") && enable_url?(url)
  end

  # 期限切れURL
  # "http://dcimg.awalker.jp/img1.php?id=xmyVbRmBBJgxKYXQEqxTuVxgcUzSKWvLp8QLIkTiF4JP9IZhz6BCgi4rmH9BKH9RSFY8krINOeaMJgoTWCCxsI0WCFpOjTMqHLT2jwgNzQdk6AMKd6HYHBzg0mUz5xicS2AaUYvEyd9TQpzH7FseIRRljR7LoFWeGDDlfi18NQnV3oiwYOwn1yzNQOS9g2Hs00bM1eo1"
  # ブログURL
  # "http://blog.nogizaka46.com/mai.shiraishi/smph/2014/10/020770.php"
  # test
  # disable
  #url = "http://dcimg.awalker.jp/img1.php?id=xmyVbRmBBJgxKYXQEqxTuVxgcUzSKWvLp8QLIkTiF4JP9IZhz6BCgi4rmH9BKH9RSFY8krINOeaMJgoTWCCxsI0WCFpOjTMqHLT2jwgNzQdk6AMKd6HYHBzg0mUz5xicS2AaUYvEyd9TQpzH7FseIRRljR7LoFWeGDDlfi18NQnV3oiwYOwn1yzNQOS9g2Hs00bM1eo1"
  # enable
  #url = "http://dcimg.awalker.jp/img1.php?id=zX28g6c0rXk4CHhwTCXTdJspTKC2wl2d8dMRsFMIJOnrk4KBVfctmlHX3l5SPpPWjBLCTBrJgcZyhYJVTplsxI5Cn4CiSTqeoxsqCdT44r7QmXKNdrWrnR0dMqUEdB9QEwKdV3amly2xLVFBzpVd1mHGXHrYwdhRNiQ6XzJYe2vzrinr8vtpwdv7v304wQAjM3ISnSij"
  #p HTMLParser.enable_url?(url)
  def self.enable_url?(raw_image_url)
    begin
      doc = Nokogiri::HTML(open(raw_image_url))
      # 空の画像が差し込まれていない場合はダウンロード可能URLとする
      doc.css("img")[0][:src] != "/img/expired.gif"
    rescue OpenURI::HTTPError => ex
      puts "Error !!!"
    end
  end

end

#data = HTMLParser.fetch("http://blog.nogizaka46.com/miona.hori/2015/10/025340.php")
#arr = data[:yearmonth].split('/')
#arr = "#{data[:yearmonth]}".split('/')
#puts arr[0]
#puts arr[1]


# Doc
# https://github.com/adelevie/parse-ruby-client

# 日付ライブラリの読み込み
require "date"

# Parseライブラリの読み込み
require 'parse-ruby-client'

# Parseライブラリの初期化
#Parse.init :application_id => ENV['PARSE_APP_ID'],
#           :api_key        => ENV['PARSE_API_KEY']
# Parse.initialize("1VXisuXpM89mXNGm56tv5shTE4xOBJj8ytl0l1gm", "XVsy36V5XilrH5BRuJa5n9Tco9ivH6q8KdpMPwXw");

# TODO: Windowsのみで発生する証明書問題によりSSL認証エラーが発生する
# 証明書を更新してみたが治らなかった、PC再起動後に現象発生するようであれば環境を再構築する
# 問題自体はWindowsの特定バージョンのrubyインストーラーなので最新のインストーラーで試す
# -> ダメな様子
# WindowsのSSL証明問題の暫定回避策として証明書の場所を指定する
# https://gist.github.com/toshiharu/5539841
#ENV['SSL_CERT_FILE'] = File.expand_path('C:\rumix\ruby\2.1\i386-mingw32\lib\ruby\2.1.0\rubygems\ssl_certs\cert.pem')

#http://www.rubydoc.info/gems/parse-ruby-client/0.3.0
# Parseライブラリの初期化
Parse.init :application_id => ENV['PARSE_APP_ID'],
           :api_key        => ENV['PARSE_API_KEY']

class ParseApiClient

  def self.push(entry)
  end

  def self.insert(data)
    #player_profile = Parse::Object.new("PlayerProfile")
    #player_profile['score'] = 12
    #puts player_profile.save
    entry = Parse::Object.new("Entry")
    # 基本情報
    entry['url'] = data[:article_url]
    entry['author'] = data[:author]
    entry['author_id'] = data[:author_id]
    entry['title'] = data[:entrytitle]
    entry['body'] = data[:entrybodyin]

    # HTML表示用
    #entry['yearmonth'] = data[:yearmonth]
    #entry['dd1'] = data[:dd1]
    #entry['dd2'] = data[:dd2]
    # TODO: メンバーIDとの紐付をする
    # 検索用
    arr = data[:yearmonth].split('/')
    entry['year'] = arr[0]
    entry['month'] = arr[1]
    entry['day'] = data[:dd1]
    entry['dayweek'] = data[:dd2]
    #date = Date.new("#{arr[0]}".to_i, "#{arr[1]}".to_i, "#{entry[:dd1]}".to_i)
    #entry['date'] = date
    # originalを接頭
    entry['original_thumbnail_url'] = data[:thumbnail_url_arr]
    entry['original_raw_img_url'] = data[:raw_img_url_arr]
    # クライアントダウンロード用URL
    entry['uploaded_thumbnail_url'] = data[:uploaded_thumbnail_url]
    entry['uploaded_raw_image_url'] = data[:uploaded_raw_image_url]
    entry['uploaded_thumbnail_file_name'] = data[:uploaded_thumbnail_file_name]
    entry['uploaded_raw_image_file_name'] = data[:uploaded_raw_image_file_name]
    puts entry.save
  end

  def self.upload_photo(dirname, filename)
    photo = Parse::File.new({
      # バイナリモードとして読み込む必要がある
      # http://qiita.com/kimitaka@github/items/f50fc3cea8243d1125a9
      :body => File.binread("#{dirname}#{filename}"),
      :local_filename => filename,
      :content_type => "image/jpeg"
    })
    photo.save
  end

end


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

  def self.insert(data, needpush)
    #player_profile = Parse::Object.new("PlayerProfile")
    #player_profile['score'] = 12
    #puts player_profile.save
    entry = Parse::Object.new("Entry")
    # 基本情報
    entry['url'] = data[:article_url]
    entry['author'] = data[:author]
    entry['author_id'] = data[:author_id]
    entry['author_image_url'] = data[:author_image_url]
    entry['title'] = data[:entrytitle]
    entry['body'] = data[:entrybodyin]

    # HTML表示用
    #entry['yearmonth'] = data[:yearmonth]
    #entry['dd1'] = data[:dd1]
    #entry['dd2'] = data[:dd2]
    # ソート用
    published = DateTime.parse(data[:published])
    entry['published'] = Parse::Date.new(published)
    # 検索用
    arr = data[:yearmonth].split('/')
    entry['year'] = arr[0]
    entry['month'] = arr[1]
    entry['day'] = data[:dd1]
    entry['dayweek'] = data[:dd2]
    date_time = DateTime.new("#{arr[0]}".to_i, "#{arr[1]}".to_i ,"#{data[:dd1]}".to_i, 0, 0, 0, 0)
    entry['date'] = Parse::Date.new(date_time)
    # originalを接頭
    entry['original_thumbnail_url'] = data[:thumbnail_url_arr]
    entry['original_raw_img_url'] = data[:raw_img_url_arr]
    # クライアントダウンロード用URL
    entry['uploaded_thumbnail_url'] = data[:uploaded_thumbnail_url]
    entry['uploaded_raw_image_url'] = data[:uploaded_raw_image_url]
    entry['uploaded_thumbnail_file_name'] = data[:uploaded_thumbnail_file_name]
    entry['uploaded_raw_image_file_name'] = data[:uploaded_raw_image_file_name]
    result = entry.save

    puts "needpush? -> #{needpush}"
    return if !needpush

    # Push
    data = { :action=> "android.shts.jp.nogifeed.UPDATE_STATUS",
             :_entryObjectId => result['objectId'],
             :_title => entry['title'],
             :_author => entry['author'],
             :_author_id => entry['author_id'],
             :_author_image_url => entry['author_image_url'],
          }
    push = Parse::Push.new(data)
    push.where = { :deviceType => "android" }
    puts push.save

    # 別Versionのアプリに通知する
    data2 = { :action=> "android.shts.jp.nogifeed.UPDATE_STATUS2",
             :_entryObjectId => result['objectId'],
             :_url => entry['url'],
             :_title => entry['title'],
             :_author => entry['author'],
             :_author_id => entry['author_id'],
             :_author_image_url => entry['author_image_url'],
             :_uploaded_thumbnail_url => entry['uploaded_thumbnail_url'],
             :_uploaded_raw_image_url => entry['uploaded_raw_image_url'],
          }
    push2 = Parse::Push.new(data2)
    push2.where = { :deviceType => "android" }
    puts push2.save
  end

  def self.upload_photo(dirname, filename)
    begin
      photo = Parse::File.new({
        # バイナリモードとして読み込む必要がある
        # http://qiita.com/kimitaka@github/items/f50fc3cea8243d1125a9
        :body => File.binread("#{dirname}#{filename}"),
        :local_filename => filename,
        :content_type => "image/jpeg"
      })
      photo.save
    rescue Parse::FileSaveError => ex
      sleep 5
      puts "*****************************************"
      puts "Failed to upload ex->#{ex} with retry!!!"
      puts "*****************************************"
      retry
    end
  end

  def self.all_member_feed
    query = Parse::Query.new("Member")
    query.get.each { |member|
      yield(member['rss_url'])
    }
  end

  def self.is_new?(url)
    Parse::Query.new("Entry").eq("url", url).get.first == nil
  end

end


# プログラムを定期実行するためのライブラリを読み込む
require 'eventmachine'
# データベースにアクセスするためのライブラリを読み込む
#require 'sinatra/activerecord'

require_relative 'htmlparser'
require_relative 'downloader'
require_relative 'parseapiclient'
require_relative 'crawler'
require_relative 'xmlparser'

# TODO: for local
#ActiveRecord::Base.configurations = YAML.load_file('database.yml')
#ActiveRecord::Base.establish_connection(:development)
#ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

#class Entries < ActiveRecord::Base; end

def fetch(published, url)

  entry = HTMLParser.fetch(url)

  if entry != nil then
    entry[:published] = published
    entry[:uploaded_thumbnail_url] = Array.new()
    entry[:uploaded_raw_image_url] = Array.new()
    entry[:uploaded_thumbnail_file_name] = Array.new()
    entry[:uploaded_raw_image_file_name] = Array.new()

    Downloader.save_image(entry) { |url_origin, saved_file_name, type|
      ret = ParseApiClient.upload_photo(Downloader::Dirname, saved_file_name)

      if type == Downloader::Thumbnail then
        entry[:uploaded_thumbnail_url].push(ret['url'])
        entry[:uploaded_thumbnail_file_name].push(ret['name'])
      else
        entry[:uploaded_raw_image_url].push(ret['url'])
        entry[:uploaded_raw_image_file_name].push(ret['name'])
      end
      # 画像アップロードに完了した場合URLの向き先を変更する
      entry[:entrybodyin] = "#{entry[:entrybodyin]}".gsub("#{url_origin}", "#{ret["url"]}")
    }
    # TODO:Net::ReadTimeoutが投げられる可能性があるのでbegin-rescueでリトライする
    begin
      # Memberテーブルを参照しメンバーを紐付ける
      query = Parse::Query.new("Member").eq("rss_url", entry[:rss_url])
      member = query.get.first
      entry[:author_id] = member['objectId']
      # ParseにEntryオブジェクトを作成する
      ParseApiClient.insert(entry)
    rescue => e
      puts "retry insert url -> #{url}"
      retry
    end
  else
    puts "entry is nil"
  end

end

arr = Array.new()
ParseApiClient.all_member_feed { |rss_url|
  XMLParser.parse(rss_url) { |published, url|
    arr.push(url)
    #if ParseApiClient.is_new?(url) then
    #  fetch(published, url)
    #else
    #  puts "already"
    #end
    #fetch(published, url) if ParseApiClient.is_new?(url)
  }
}

puts arr.count

# TODO:過去の記事のURLすべてを取得する
#url_arr = Crawler.past_entry_url
#url_arr.each do |url|
#  # 10000件が上限なので9500を超えた場合は古いレコードを削除する
#  if Entries.count >= 9500
#    Entries.first.delete
#  end
#  # URLをDBに保存
#  Entries.where(:url => url).first_or_create do |e|
#    puts "new record -> #{e}"
#    # 各URLをパースしてDBへ保存する
#    # とりあえずDBに格納して上限になったらどうなるか調査
#    fetch(url)
#  end
#end

# TODO:新着を記事を監視する
#EM.run do
#  EM::PeriodicTimer.new(60) do
#    XMLParser.parse { |element|
#      puts "routine task start"
#      url = element.elements['link'].attribute('href')
#      Articles.where(:url => url).first_or_create do |e|
#        fetch(url)
#      end
#    }
#  end
#end

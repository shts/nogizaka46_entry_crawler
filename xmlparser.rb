# http://docs.ruby-lang.org/ja/2.1.0/library/rexml=2fdocument.html
# http://d.hatena.ne.jp/aoi_273/20090311/1236764850

# URLにアクセスするためのライブラリを読み込む
require 'open-uri'

# XMLをパースするためのライブラリを読み込む
require 'rexml/document'

class XMLParser

  def self.parse

    # RSSフィードを取得する
    url = 'http://blog.nogizaka46.com/atom.xml'
    xml = open(url)

    # 取得したフィード(XML)の読み込み
    doc = REXML::Document.new(open(xml))

    # 解析する
    doc.elements.each('feed/entry') do |element|
      yield(element)
    end

  end

end

#XMLParser.parse { |e|
#  puts e.elements['link'].attribute('href')
#}

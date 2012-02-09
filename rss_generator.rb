require './article_fetcher.rb'
require './postparser.rb'

require 'rss/maker'
require 'yaml'

class RssGenerator
  def initialize
    configFile = YAML.load(File.new("config.yaml")) 
    @blogTitle = configFile["blogTitle"]
    @baseUrl = configFile["baseUrl"]
    @rssDesc = configFile["rssDesc"]
    @fetcher = ArticleFetcher.new
    @version = "2.0"
    @parser = PostParser.new
  end
#TODO / FIXME: Rendered articles should be used here...
  def generateFeed(n = 10) # 10 Articles in RSS per default
    articles = @fetcher.fetchAll
    articles.slice!(0...articles.length - n)
    
    rssContent = RSS::Maker.make(@version) do |m|
      m.channel.title = @blogTitle
      m.channel.link = @baseUrl
      m.channel.description = @rssDesc
      date = String.new
      articles.each do |article|
        article.each do |filename, content|
          date =  @parser.parseDate(filename)
          cont = content
        end
        i = m.items.new_item
        i.title = "foo"
        i.link = "http://filzo.de"
        i.date = date
        i.content = "foo"
      end
    end
    #articles
    puts rssContent
  end
end


gen = RssGenerator.new
articles = gen.generateFeed



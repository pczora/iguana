require './article_fetcher.rb'
require './article_parser.rb'
require 'rss/maker'
require 'yaml'
require 'maruku'

class RssGenerator
  def initialize
    configFile = YAML.load(File.new("config.yaml")) 
    @blogTitle = configFile["blogTitle"]
    @baseUrl = configFile["baseUrl"]
    @rssDesc = configFile["rssDesc"]
    @fetcher = ArticleFetcher.new
    @articleMarkdownDir = ("./articles/")
    @version = "2.0"
    @parser = ArticleParser.new
  end

  # Generates the RSS feed based on already rendered articles. That's not that clever, so I'll write another function which renders the feed from the Markdown files.
  def generateFeed(n = 10) # 10 Articles in RSS per default
    articles = @fetcher.fetchAllRendered
    articles.slice!(0...articles.length - n)
    
    rssContent = RSS::Maker.make(@version) do |m|
      m.channel.title = @blogTitle
      m.channel.link = @baseUrl
      m.channel.description = @rssDesc
      date = String.new
      meta = String.new
      htmlFile = String.new
      cont = String.new
      articles.each do |article|
        article.each do |filename, content|
          htmlFile = filename
          metaString = File.new(@articleMarkdownDir + filename.chomp(".html") + ".markdown", "r")
          meta = YAML.load(metaString.read.split("META_END")[0])
          date =  @parser.parseDate(filename)
          cont = content
        end
        i = m.items.new_item
        i.title = meta["title"]
        i.link = @baseUrl + "articles/" + htmlFile 
        i.date = date
        #FIXME: cont contains full single article template. That sucks.
        #i.description = cont
      end
    end
    #articles
    puts rssContent
    rssFile = File.new("./html/feed.rss", "r+")
    rssFile.truncate(0)
    rssFile.write(rssContent)
  end

  # Generates RSS feed based on the raw Markdown input

  def updateFeed(n = 10)
    articles = @fetcher.fetchAll
    articles.slice!(0...articles.length - n)
    
    rssContent = RSS::Maker.make(@version) do |m|
      m.channel.title = @blogTitle
      m.channel.link = @baseUrl
      m.channel.description = @rssDesc
      date = String.new
      meta = String.new
      htmlFile = String.new
      description = String.new
      articles.each do |article|
        article.each do |filename, content|
          htmlFile = filename
          puts filename
          #metaString = File.new(@articleMarkdownDir + filename.chomp(".html") + ".markdown", "r")
          meta = YAML.load(content.split("META_END")[0])
          date =  @parser.parseDate(filename)
          description = Maruku.new(content.split("META_END")[1]).to_html
        end
        i = m.items.new_item
        i.title = meta["title"]
        i.link = @baseUrl + "articles/" + htmlFile 
        i.date = date
        i.description = description
      end
    end
    #articles
    puts rssContent
    rssFile = File.new("./html/feed.rss", "r+")
    rssFile.truncate(0)
    rssFile.write(rssContent)
  end
end

#gen = RssGenerator.new
#gen.updateFeed





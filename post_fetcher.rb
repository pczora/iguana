class PostFetcher
  #TODO: Clean up attributes
  attr_accessor :articleDir, :htmlArticleDir, :templateDir, :articleTemplate, :indexTemplate

  def initialize
    @articleDir = Dir.new("articles/")
    @htmlArticleDir = Dir.new("html/articles/")
    @templateDir = Dir.new("templates/")
    @articleTemplate = File.new(@templateDir.path + "article.haml", "r")
    @indexTemplate = File.new(@templateDir.path + "index.haml", "r")
    @articleEngine = Haml::Engine.new(@articleTemplate.read)
    @indexEngine = Haml::Engine.new(@indexTemplate.read)
    @htmlIndexFile = File.new("html/index.html", "r+")
    @singleArticleTemplate = File.new(@templateDir.path + "single_article.haml", "r")
    @singleArticleEngine = Haml::Engine.new(@singleArticleTemplate.read)
    @configFile = YAML.load(File.new("config.yaml"))
    @blogTitle = @configFile["blogTitle"]
    puts @blogTitle
    @htmlIndexFile.truncate(0)
    
    end
end

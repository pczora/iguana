require 'yaml'

class ArticleFetcher
  #TODO: Clean up attributes
  attr_accessor :articleDir, :htmlArticleDir, :templateDir, :articleTemplate, :indexTemplate

  def initialize
    @articleDir = Dir.new("articles/")
    @renderedArticleDir = Dir.new("html/articles/")
    @configFile = YAML.load(File.new("config.yaml"))
  end

  def fetchAll
    articleArray = Array.new
    #articleHash = Hash.new
    filenames = @articleDir.entries
    filenames.delete(".")
    filenames.delete("..")
    filenames.sort!
   # filenames.reverse!
    
    filenames.each do |filename|
      contents = File.open(@articleDir.path + filename, "r").read
      # articleHash.merge!({filename => contents})
      articleArray << {filename => contents}
    end
    articleArray
  end

  def fetchAllRendered
    articleArray = Array.new
    #articleHash = Hash.new
    filenames = @renderedArticleDir.entries
    filenames.delete(".")
    filenames.delete("..")
    filenames.delete("css")
   # filenames.sort!
   # filenames.reverse!
    
    filenames.each do |filename|
      contents = File.open(@renderedArticleDir.path + filename, "r").read
      # articleHash.merge!({filename => contents})
      articleArray << {filename => contents}
    end
    articleArray
  end
end


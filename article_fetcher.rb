require 'yaml'

class ArticleFetcher
  #TODO: Clean up attributes
  attr_accessor :articleDir, :htmlArticleDir, :templateDir, :articleTemplate, :indexTemplate

  def initialize
    @articleDir = Dir.new("articles/")
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
end

#fetcher = ArticleFetcher.new
#articles =  fetcher.fetchAll
#puts articles



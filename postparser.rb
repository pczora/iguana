# -*- coding: utf-8 -*-
require 'maruku'
require 'haml'
require 'yaml'

class PostParser

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
 
  def parse
    puts "Rendering posts..."
    filenames = @articleDir.entries
    filenames.delete(".")
    filenames.delete("..")
    filenames.sort!
    filenames.reverse!
    postsString = String.new()
    filenames.each do |filename|
      puts "Rendering: \t" + filename
      filename_split = filename.split("_")
      dateString = filename_split[2] + "." + filename_split[1] + "." + filename_split[0]
      
      file = File.new(articleDir.path + filename)
      puts "Parsing Metadata..."
      contents = file.read;
      parts = contents.split("META_END");
      meta = YAML.load(parts[0])
      title =  meta["title"]
      tags = meta["tags"]
      tagString = String.new
      
      tags.each do |tag|
        tagString << tag
        if tag != tags.last
          tagString << ", "
        end
      end
      
      puts "Converting Markdown to HTML..."
      article_text = Maruku.new(parts[1]).to_html 
      
      filename_split.slice!(0, 3)
      output_filename = filename_split.join("_")
      output_filename.chomp!(".markdown")
      output_filename << ".html"
      puts "Output filename: \t" + output_filename
      
      

      renderedSingleArticle = @singleArticleEngine.render(Object.new, :blogTitle => @blogTitle,  :title => title, :article_text => article_text, :dateString => dateString, :tagString => tagString)
      #renderedSingleArticlePage = @indexEngine.render(Object.new, :blogTitle => @blogTitle, :postsString => renderedSingleArticle)
      renderedArticle = @articleEngine.render(Object.new, :title => title,  :article_text => article_text, :dateString => dateString, :tagString => tagString, :filename => output_filename)
      

      
      outputFile = File.new(htmlArticleDir.path + output_filename, "w")
      puts "Writing " + output_filename
      outputFile.write(renderedSingleArticle)
     # puts renderedArticle
      postsString << renderedArticle
    end
    #TODO: Render index
    
    #puts postsString
    puts "Rendering index.html"
    renderedIndex = @indexEngine.render(Object.new, :blogTitle => @blogTitle, :postsString => postsString)
    @htmlIndexFile.write(renderedIndex)
  end
end

p = PostParser.new
p.parse

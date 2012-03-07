# -*- coding: utf-8 -*-
require 'maruku'
require 'haml'
require 'yaml'
require './article_fetcher.rb'

class ArticleParser

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
    #puts @blogTitle
    @articlesPerPage = @configFile["articlesPerPage"]
    @htmlIndexFile.truncate(0)
    @articleFetcher = ArticleFetcher.new
  end 
 
  def parse
    puts "Rendering posts..."
    renderedArticles = Array.new
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
      #puts "Replacing _IMGPATH_..."
      #parts[1].gsub!("_IMGPATH_", "Bilderpfad")
      puts "Converting Markdown to HTML..."
      single_article_text = Maruku.new(parts[1].gsub("_IMGPATH_", "../../images")).to_html 
      index_article_text = Maruku.new(parts[1].gsub("_IMGPATH_", "../images")).to_html
     # filename_split.slice!(0, 3)
      output_filename = filename_split.join("_")
      output_filename.chomp!(".markdown")
      output_filename << ".html"
      puts "Output filename: \t" + output_filename
      
      

      renderedSingleArticle = @singleArticleEngine.render(Object.new, :blogTitle => @blogTitle,  :title => title, :article_text => single_article_text, :dateString => dateString, :tagString => tagString)
      
      #renderedSingleArticlePage = @indexEngine.render(Object.new, :blogTitle => @blogTitle, :postsString => renderedSingleArticle)
      renderedArticle = @articleEngine.render(Object.new, :title => title,  :article_text => index_article_text, :dateString => dateString, :tagString => tagString, :filename => output_filename)
      renderedArticles.push(renderedArticle)

      
      outputFile = File.new(htmlArticleDir.path + output_filename, "w")
      puts "Writing " + output_filename
      outputFile.write(renderedSingleArticle)
     # puts renderedArticle
      postsString << renderedArticle
    end
   
    
    #puts postsString
    #puts renderedArticles
    puts "Rendering index.html..."
    count = renderedArticles.size
    fraction = count % @articlesPerPage
    puts fraction
    if fraction == 0
      pages = count / @articlesPerPage
    else
      pages = (count / @articlesPerPage + 0.5).round
    end
    puts "Pages: " + pages.to_s
    
    renderedArticles.reverse!
    for i in 1..pages do
      if i == 1
        filename = "index.html"
        prevLink = ""
      else
        filename = "page" + i.to_s + ".html"
        if i == 2
          prevLink = "<a href = \"index.html\"> Vorherige Seite </a>"
        else
          prevLink = "<a href = \"page" + (i-1).to_s + ".html\"> Vorherige Seite </a>"
        end
      end
      if i < pages
        nextLink = "<a href = \"page" + (i+1).to_s + ".html\"> nächste Seite </a>"
      else
        nextLink = ""
      end
      
      file = File.new("./html/" + filename, "w")
      
      articlesString = String.new
      articlesString = renderedArticles.pop(@articlesPerPage).reverse.join("\n")
      articlesString.gsub("_IMGPATH_", "../../images/")
      renderedIndex = @indexEngine.render(Object.new, :blogTitle => @blogTitle, :postsString => articlesString, :prevLink => prevLink, :nextLink => nextLink)
      file.write(renderedIndex)
    end
    
    #puts articlesString
    #renderedIndex = @indexEngine.render(Object.new, :blogTitle => @blogTitle, :postsString => postsString, :prevLink => prevLink, :nextLink => nextLink)
    # @htmlIndexFile.write(renderedIndex)
  end

  def parseDate(filename) 
    puts filename
    filename_split = filename.split("_")
    dateString = filename_split[2] + "." + filename_split[1] + "." + filename_split[0]
    dateString 
  end
end
p = ArticleParser.new
p.parse

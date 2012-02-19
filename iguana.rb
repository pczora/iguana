#!/usr/bin/ruby
require './article_parser.rb'
require './rss_generator.rb'

class Iguana
  def initialize
    @article_parser = ArticleParser.new
    @rss_generator = RssGenerator.new
  end

  
  def parse_arguments
    command = ARGV[0]
    case command
    when nil
      puts "No command given..."
    when "render"
      puts "Rendering"
      case ARGV[1]
        when "all"
        puts "Rendering everything..."
        @article_parser.parse
        @rss_generator.updateFeed
      end
    else
      puts "Unrecognized command: " + command
    end
  end
end

iguana = Iguana.new
iguana.parse_arguments

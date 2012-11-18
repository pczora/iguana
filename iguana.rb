#!/usr/bin/ruby
require 'rubygems'
require './article_parser.rb'
require './rss_generator.rb'
require './recursive_ftp.rb'

class Iguana
  def initialize
    @article_parser = ArticleParser.new
    @rss_generator = RssGenerator.new
    @configFile = YAML.load(File.new("config.yaml"))
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
    when "new"
      case ARGV[1]
      when "article"
        case ARGV[2]
        when nil 
          puts "No name provided. Aborting."
        else 
          date = Time.new
          if date.month > 9
            month = date.month.to_s
          else
            month = "0" + date.month.to_s
          end
          if date.day > 9
            day = date.day.to_s
          else
            day = "0" + date.day.to_s
          end
          dateString = date.year.to_s + "_" + month + "_" + day
          puts dateString
          filename = dateString + "_" + ARGV[2] + ".markdown"
          puts "Creating new article: " + filename
          file = File.new("./articles/" + filename, "w")
          file.write(File.new("./templates/metaheader.tmpl").read)
        end
      end
	when "pull"
		puts "Pulling..."
		ftp = RecursiveFTP.new(@configFile["ftp_host"])
		ftp.login(@configFile["ftp_user"], @configFile["ftp_password"])
		puts "Downloading articles..."
		ftp.download_dir(@configFile["ftp_basedir"] + "articles/", "./articles/")
		puts "Downloading HTML files..."
		ftp.download_dir(@configFile["ftp_basedir"] + "html/", "./html/")
		puts "Downloading templates..."
		ftp.download_dir(@configFile["ftp_basedir"] + "templates/", "./templates/")
	when "push"
		puts "Pushing"
		ftp = RecursiveFTP.new(@configFile["ftp_host"])
		ftp.login(@configFile["ftp_user"], @configFile["ftp_password"])
		puts "Uploading articles..."
		ftp.upload_dir("./articles/", @configFile["ftp_basedir"] + "articles/")
		puts "Uploading HTML files..."
		ftp.upload_dir("./html/",  @configFile["ftp_basedir"] + "html/")
		puts "Uploading Templates..."
		ftp.upload_dir("./templates/",  @configFile["ftp_basedir"] + "templates/")
    else
      puts "Unrecognized command: " + command
    end
  end
end


iguana = Iguana.new
iguana.parse_arguments

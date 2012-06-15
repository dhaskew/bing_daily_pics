#!/usr/bin/env ruby

require 'rss'
require 'open-uri'
require 'logger'

require 'ruby-growl'

# useful documentation
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/rss/rdoc/RSS/Parser.html
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/open-uri/rdoc/OpenURI.html
# http://www.ruby-doc.org/core-1.9.3/String.html
# http://www.ruby-doc.org/core-1.9.3/File.html


@log = Logger.new(STDOUT)

@log.level = Logger::DEBUG # DEBUG,INFO,WARN,ERROR,FATAL

# alert on program start
g1_result = `growl -H localhost -t "Bing Pic of the Day" -m "Refresh Started" -n "Ruby Script : Bing Picture of the Day"`

enclosures = []

# the location to download the files to
downloads_dir = "/Users/dhaskew/pictures/bing_pics/"

#if(downloads_dir == "/Users/dhaskew/pictures/bing_pics/")
#  @log.fatal "You must change the default download directory to something more appropriate!"
#  exit 0
#end

# create directory if it doesn't exist
if(!File.exists?(downloads_dir))
  @log.fatal "The folder specified in downloads_dir does not exist! Please create and rerun script."
  exit 0
  #puts "creating directory #{downloads_dir}"
  #Dir.mkdir(downloads_dir)
  #puts "directory created"
end

@log.debug "RSS fetch and parse : START"

url = 'http://feeds.feedburner.com/bingimages'
open(url) do |rss|
  feed = RSS::Parser.parse(rss,do_validate=false)
  #puts "Title: #{feed.channel.title}"
  feed.items.each do |item|
    #puts "Item: #{item.title}"
    #puts "Image Link: #{item.link}"
    #puts "Enclosure Link: #{item.enclosure.url}"
    enclosures << item.enclosure.url
  end
end

@log.debug "RSS fetch and parse : END" 

#puts enclosures

new_pictures = false

enclosures.each do |file|
  fpart1 = file[0,file.index('%2f')+3]
  fname = file[file.index('%2f')+3,file.length]
  
  output_file = downloads_dir + fname
  
  #puts fpart1
  #puts fname
  
  if(!File.exists?(fname))
  
    File.open(output_file, 'wb') do |fo|
      fo.write open(file).read 
    end
    
    new_pictures = true
    
  else
    puts "File Exists : #{file}"
  end
  
  
end

# alert on status of pictures
if(new_pictures)
  g1_result = `growl -H localhost -t "Bing Pic of the Day" -m "New Pictures Available" -n "Ruby Script : Bing Picture of the Day"`
else
  g1_result = `growl -H localhost -t "Bing Pic of the Day" -m "No New Pictures Downloaded" -n "Ruby Script : Bing Picture of the Day"`
end  

# alert when program done
g1_result = `growl -H localhost -t "Bing Pic of the Day" -m "Refresh Complete" -n "Ruby Script : Bing Picture of the Day"`

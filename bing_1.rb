#!/usr/bin/env ruby

require 'rss'
require 'open-uri'

# useful documentation
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/rss/rdoc/RSS/Parser.html
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/open-uri/rdoc/OpenURI.html
# http://www.ruby-doc.org/core-1.9.3/String.html
# http://www.ruby-doc.org/core-1.9.3/File.html

enclosures = []

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

#puts enclosures

enclosures.each do |file|
  fpart1 = file[0,file.index('%2f')+3]
  fname = file[file.index('%2f')+3,file.length]
  
  #puts fpart1
  #puts fname
  
  if(!File.exists?(fname))
  
    File.open(fname, 'wb') do |fo|
      fo.write open(file).read 
    end
  else
    puts "File Exists : #{file}"
  end
  
  
end



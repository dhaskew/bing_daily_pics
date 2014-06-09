#!/usr/bin/env ruby

require 'rss'
require 'open-uri'
require 'logger'
require 'logger/colors'      #gem install logger-colors
require 'terminal-notifier'  #gem install terminal-notifier

# useful documentation
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/rss/rdoc/RSS/Parser.html
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/open-uri/rdoc/OpenURI.html
# http://www.ruby-doc.org/core-1.9.3/String.html
# http://www.ruby-doc.org/core-1.9.3/File.html

@log = Logger.new(STDOUT)

@log.level = Logger::DEBUG # DEBUG,INFO,WARN,ERROR,FATAL

#ensure environment is setup properly
env_vars = %w{BING_DIR}

not_defined = env_vars.find_all { |var| ENV[var] == nil }

unless not_defined.empty?
  @log.fatal "The following environment variables are missing and should be defined: #{not_defined.join(', ')}"
  if (not_defined.include?('BING_DIR'))
    @log.info "BING_DIR should point to the directory used to store the images.  It must exist and be of the form '/directory/subdir/'"
  end
  exit 0
end

# alert on program start
TerminalNotifier.notify("Bing: Refresh Started", :activate => 'activate test', :title => "Bing Pic of the Day")

enclosures = []

# the location to download the files to
downloads_dir = ENV["BING_DIR"] # should be set to something like "/Users/username/Pictures/"

# create directory if it doesn't exist
if(!File.exists?(downloads_dir))
  @log.fatal "The folder specified in BING_DIR (#{ENV["BING_DIR"]}) does not exist! Please create and rerun script."
  exit 0
end

@log.debug "RSS fetch and parse : START"

url = 'http://feeds.feedburner.com/bingimages'
open(url) do |rss|
  feed = RSS::Parser.parse(rss,do_validate=false)
  feed.items.each do |item|
    enclosures << item.enclosure.url
  end
end

@log.debug "RSS fetch and parse : END" 

new_pictures = false

enclosures.each do |file|
  fpart1 = file[0,file.index('%2f')+3]
  fname = file[file.index('%2f')+3,file.length]
  
  output_file = downloads_dir + fname
  
  if(!File.exists?(output_file))
  
    File.open(output_file, 'wb') do |fo|
      fo.write open(file).read
      @log.info "File Created : #{output_file}"
    end
    
    new_pictures = true
    
  else
    @log.info "File Exists : #{output_file}"
  end
end

# alert on status of pictures
if(new_pictures)
  TerminalNotifier.notify("Bing: New Pictures Available", :activate => 'activate test', :title => "Bing Pic of the Day")
else
  TerminalNotifier.notify("Bing: No New Pictures", :activate => 'activate test', :title => "Bing Pic of the Day")
end  

# alert when program done
TerminalNotifier.notify("Bing: Refresh Complete", :activate => 'activate test', :title => "Bing Pic of the Day")

#!/usr/bin/env python
import os
import md5
import pprint
import sys
import subprocess
from time import strftime
from urllib import URLopener
from urllib2 import urlopen
from xml.dom.minidom import parseString

# Defines source and destination of image
rss_feed = 'http://feeds.feedburner.com/bingimages';
dst_dir = os.path.expanduser('~/Pictures/DeskFeed/')

SCRIPT = """/usr/bin/osascript<<END
tell application "Finder"
set desktop picture to POSIX file "%s"
end tell
END"""


def set_desktop_background(destination):
  subprocess.Popen(SCRIPT%destination, shell=True)

def parseFeed(rss):
  destination = "%s%s.jpg" % (dst_dir, strftime( "%y-%m-%d"))
  if os.path.exists(destination):
    sys.exit(0)



  try:
    rss_contents = urlopen( rss )
  except:
    print "Failed to read rss feed %s" % rss
    return
  rss_src = rss_contents.read()
  rss_contents.close()
  dom = parseString( rss_src )
  firstitem = dom.getElementsByTagName('item')[0]
  link = firstitem.getElementsByTagName( 'enclosure' )[0].getAttribute('url')
  URLopener().retrieve(link, destination)
  #set_desktop_background(destination)


def main():
  parseFeed(rss_feed)

if __name__ == "__main__":
  main()
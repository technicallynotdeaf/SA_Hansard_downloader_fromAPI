#
#  Scraper to read sitting dates for SA Parliament 
# 
# In order to facilitate automatically downloading each day's hansard
# without having to manually download and save each day
# 
# This version of code hacked together by Alison Keen Oct/Nov 2016
# 
# Initial starting point blatantly plagiarized from 
# 
# https://github.com/openaustralia/example_ruby_phantomjs_scraper/blob/master/scraper.rb
# 
# (Thankyou OpenAustralia people, that's a really helpful example!!)
#

require 'scraperwiki'
require 'capybara'
require 'capybara/poltergeist'

# from Hansard server content-type is text/html, attachment is xml
json_download_year_url = "https://hansardpublic.parliament.sa.gov.au/_vti_bin/Hansard/HansardData.svc/GetYearlyEvents/"

xml_download_url = "http://hansardpublic.parliament.sa.gov.au/_layouts/15/Hansard/DownloadHansardFile.ashx?t=tocxml&d=HANSARD-10-17452"

fragment_download_url = "https://hansardpublic.parliament.sa.gov.au/_layouts/15/Hansard/DownloadHansardFile.ashx?t=fragment&d=HANSARD-11-24737"
# From own server it sends the file as content-type text/xml, 
# pipe_download_url = "http://sa.pipeproject.info/xmldata/upper/HANSARD-10-17452.xml"

fF_user_agent_string = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.90 Safari/537.36"

$debug = TRUE
$csvoutput = FALSE
$sqloutput = FALSE

class JSONDownloader

  def init
    capybara = Capybara::Session.new(:poltergeist)
  
    # The Javascript is buggy, we have to ignore errors
    # or we get nowhere
    capybara.driver.browser.js_errors = false
    capybara.driver.headers = { "User-Agent" => fF_user_agent_string }
  
    # Read in the page
    capybara.visit(xml_download_url)
  end

  def download_year_index(year)
    url_to_load = json_download_year_url + year.to_s
    filename = "#{year.to_s}_hansard.json"
    
    puts "downloading file"   
    `curl --output #{filename} "#{url_to_load}"`
  end

#  useful for troubleshooting... 
#  puts capybara.status_code
#  puts capybara.response_headers
  
  # puts capybara.page.source

end #end JSONDownloader class

JSONDownloader.download_year_index(2016) 

#  `curl --silent --output data/representatives.csv "https://api.morph.io/alisonkeen/SA_members_for_OA_parser/data.csv?key=#{conf.morph_api_key}&query=select%20*%20from%20'data'"`
#  `curl --silent --output data/senators.csv "https://api.morph.io/alisonkeen/SA_senators_for_OA_parser/data.csv?key=#{conf.morph_api_key}&query=select%20*%20from%20'data'"`

# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})

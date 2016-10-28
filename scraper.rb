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
require 'capybara/poltergeist'

calendar_search_url = "http://hansardpublic.parliament.sa.gov.au/#/search/1"


capybara = Capybara::Session.new(:poltergeist)


# Read in a page
capybara.visit(calendar_search_url)

# Find somehing on the page using css selectors
puts capybara.find('div.scheduler').text

# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})

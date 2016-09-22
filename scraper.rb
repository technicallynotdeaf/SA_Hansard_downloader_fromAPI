# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

require 'scraperwiki'
require 'mechanize'

calendar_search_url = "http://hansardpublic.parliament.sa.gov.au/#/search/1"


agent = Mechanize.new

# Read in a page
page = agent.get(calendar_search_url)

# Find somehing on the page using css selectors
puts page.search('div.scheduler')

puts "The problem here is that each month in the calendar has the dates populated dynamically using JavaScript on load."
puts "I don't know how to scrape dynamically loaded pages, yet..." 

# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})

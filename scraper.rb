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

calendar_search_url = "http://hansardpublic.parliament.sa.gov.au/#/search/1"


capybara = Capybara::Session.new(:poltergeist)

# The Javascript is buggy, we have to ignore errors
# or we get nowhere
capybara.driver.browser.js_errors = false

# Read in the page
capybara.visit(calendar_search_url)

# Read the Legend to find out the dates with data of interest... 
legend_divs = capybara.all('div.hansard-legend')

# declare an empty array to put class IDs into
list_of_class_ids = []

# Read the class names handily supplied with the legend, 
# identifying dates of interest... 
legend_divs.each do |legend_item|
  spans = legend_item.all('span')
  class_details = []
  class_details[0] = spans[0]['class'].to_s
  class_details[1] = spans[1].text.to_s
  list_of_class_ids.push class_details
end #end iterating over legend items

# Example structure of what html code looks like:
# <td role="gridcell"> 
# <a class="k-link date-ha-lc-style k-state-hover" 
# data-value="2016/1/9" title="Tuesday, 9 February 2016" href="#"> 
#   <div class="date-ha-lc" title="House of Assembly, 
#     Legislative Council" >9</div>
# </a>
# </td>
# 
list_of_class_ids.each do |type_of_date|
  search_string = 'a.' + type_of_date[0] + '-style'
#  puts "checking for: " + search_string
  puts "Scheduled sitting days for: " + type_of_date[1]
  date_cells = capybara.all(search_string)

  #Start a count of how many days are found
  date_counter = 0

  date_cells.each do |sitting_date| 
    date_string = sitting_date['data-value'].to_s
    if(date_string.nil? || date_string.empty?) 
      #skip
    else 
      puts date_string
      date_counter += 1
      
      #create data object and save sitting date to table
      data = {
        date: date_string,
        type_of_sitting_day: type_of_date[1].to_s
      }
      ScraperWiki.save_sqlite([:date], data)
    end
  end # end iterating over found sitting dates

  puts date_counter.to_s + " sitting days found."
end # end of iterating over sitting date types


# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})

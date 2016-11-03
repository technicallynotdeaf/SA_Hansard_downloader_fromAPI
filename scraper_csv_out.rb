
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
xml_download_url = "http://hansardpublic.parliament.sa.gov.au/_layouts/15/Hansard/DownloadHansardFile.ashx?t=tocxml&d="

$debug = FALSE
$csvout = TRUE

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
  class_details = spans[0]['class'].to_s
  list_of_class_ids.push class_details
end #end iterating over legend items

# let's just grab the first three since we don't care about estimates yet.
# NB estimates download URLS may be different...
wanted_class_ids = []
wanted_class_ids.push list_of_class_ids[0]
wanted_class_ids.push list_of_class_ids[1]
wanted_class_ids.push list_of_class_ids[2]

puts wanted_class_ids unless $csvout


puts '"Date","URL","House"' if $csvout

# Example snippet of code for each sitting date:
# <td role="gridcell"> 
# <a class="k-link date-ha-lc-style k-state-hover" 
# data-value="2016/1/9" title="Tuesday, 9 February 2016" href="#"> 
#   <div class="date-ha-lc" title="House of Assembly, 
#     Legislative Council" >9</div>
# </a>
# </td>
# 
wanted_class_ids.each do |type_of_date|
  search_string = 'a.' + type_of_date + '-style'
  puts "checking for: " + search_string if $debug

  date_cells = capybara.all(search_string)

  #Start a count of how many days are found
  date_counter = 0

  date_cells.each do |sitting_date| 
    date_string = sitting_date['data-value'].to_s

#    puts sitting_date['outerHTML'].to_s if $debug

    # Just a hunch that writing data out to Sqlite deletes something?
#    sitting_type = type_of_date[1].to_s

    sitting_date.trigger('click')
    puts "clicked!" unless $csvout
   
    # There will be one or two divs containing info about
    # a relevant XML file  
    h_containers = capybara.all('div.date-event-container')

    h_containers.each do |linkbox| 
      
#      puts linkbox['outerHTML'].to_s

      transcript_type = linkbox.find('div.date-event-name').text
#      puts "Transcript Type: " + transcript_type

      hansard_file_ID = linkbox.find('div.hansard-icon-xml')['data-value'].to_s
#      puts "Hansard File ID: " + hansard_file_ID

      # the date string has a "/" in it, need to replace with "."
      # NB the really sneaky thing is, the dates are wrong - 
      # "Month" is actually m-1 as January is month 'zero'. 
      date_string = date_string.gsub("/",".")

      d = text.match(/([0-9]+).([0-9]+).([0-9]+)/)
 
      day = d[1].to_i
      month = d[2].to_i + 1
      year = d[3].to_i

      date_string = day.to_s + "." + month.to_s + "." + year.to_s
  


# Once you have each hansard-icon-xml div you can use this line
      # to construct the download URL - but there's a hansard-icon-xml div
      # in each date-event-container, as well as the name of who or what is 
      # sitting. 
      file_download_URL = xml_download_url + hansard_file_ID + ".xml"
#      puts "URL: "+  file_download_URL

      #create data object and save sitting date to table
      data = {
        date: date_string,
        xml_file_url: file_download_URL,
        type_of_transcript: transcript_type
      }

      puts data if $debug

#      ScraperWiki.save_sqlite([:date], data)
      puts '"' + date_string + '","' + file_download_URL + '","' +
        transcript_type + '"' if $csvout
      date_counter += 1

    end

  end # end iterating over found sitting dates

  puts date_counter.to_s + " sitting days found." unless $csvout
end # end of iterating over sitting date types


# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})

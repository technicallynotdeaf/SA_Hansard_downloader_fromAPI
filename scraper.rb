#
# Scraper to download SA Hansard XML files using API
# 
# In order to facilitate automatically downloading each day's hansard
# without having to manually download and save each day
# 
# This version of code hacked together by Alison Keen Nov 2016
#
# SA Parliament Hansard API Docs are here: 
# 
# https://parliament-api-docs.readthedocs.io/en/latest/south-australia/#read-data 
#
# Apologies for flagrant violation of coding conventions.
# I think I realised halfway through this one you're supposed to use
# camelCase for variables... oops 

require 'scraperwiki'

# from Hansard server content-type is text/html, attachment is xml

xml_download_url = "http://hansardpublic.parliament.sa.gov.au/_layouts/15/Hansard/DownloadHansardFile.ashx?t=tocxml&d=HANSARD-10-17452"

fragment_download_url = "https://hansardpublic.parliament.sa.gov.au/_layouts/15/Hansard/DownloadHansardFile.ashx?t=fragment&d=HANSARD-11-24737"
$debug = TRUE
$csvoutput = FALSE
$sqloutput = FALSE

module JSONDownloader

  # The URLs to access the API... 
  @json_download_year_url = "https://hansardpublic.parliament.sa.gov.au/_vti_bin/Hansard/HansardData.svc/GetYearlyEvents/"

  @json_download_toc_url = "https://hansardpublic.parliament.sa.gov.au/_vti_bin/Hansard/HansardData.svc/GetByDate"

  def JSONDownloader.download_all_fragments(year) 
  
    #Annual Index is a special case - different API URL  
    annualIndexFilename = download_annual_index(year)

    get_toc_hash(annualIndexFilename) do |toc_saph_filename| 

      # then we read and load the JSON
      # and request each fragment for each day... 
      download_toc(toc_saph_filename) 

      # then get the hash of fragments from each TOC file... 

        # and download each one. 

    end


  end

  # read horrible JSON file and get toc filenames
  def JSONDownloader.get_toc_hash(annualIndexFilename)

    puts "Testing if JSON parsing even works" 
    json = JSON.parse '{"foo":"bar", "ping":"pong"}'
    puts json.keys # prints "bar"

    puts "Parsing annual index #{annualIndexFilename}" if $debug
    rawJSON = File.read(annualIndexFilename)
    loadedJSON = JSON.load rawJSON # Why is this returning a String!?
    parsedJSON = JSON.load loadedJSON #will trying twice help?

    parsedJSON.each do |event|
      puts event.keys if $debug
      puts "Available for..." + event['date'].to_s
      puts event['Events'].to_s
    end

#    obj['date'].each do |date| 
#      puts "Date..." if $debug
#    end

  end

  # Puts the raw, no-line-breaks JSON into a file and
  # returns the file name.
  def JSONDownloader.download_annual_index(year)

    url_to_load = @json_download_year_url + year.to_s
    filename = "#{year.to_s}_hansard.json"
    
    puts "downloading file"   
    `curl --output #{filename} "#{url_to_load}"`
 
    filename # The output of the method. ruby doesn't use 'return'
  end




  # "saph_filename" will be soemthing like "HANSARD-10-2343" with no
  # file extension. 
  def JSONDownloader.download_toc(saph_filename)

    request_headers = " -H \"Content-Type: application/json; charset=UTF-8\" -H \"Accept: */*\" --data-binary \"{\"\"DocumentId\"\" : \"\"#{saph_filename}\"\"}\""

    url_to_load = @json_download_toc_url  + request_headers

    toc_filename = "#{saph_filename}_hansard.json"

    # First we download the table of contents    
    puts "downloading TOC file"   
    `curl --output #{toc_filename} "#{url_to_load}"`

    # Then we turn it into XML... 
 
    filename # The output of the method. ruby doesn't use 'return'
  end

end #end JSONDownloader class

JSONDownloader.download_all_fragments(2016) if $debug


# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})

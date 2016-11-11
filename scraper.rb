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

require 'scraperwiki'

# from Hansard server content-type is text/html, attachment is xml

xml_download_url = "http://hansardpublic.parliament.sa.gov.au/_layouts/15/Hansard/DownloadHansardFile.ashx?t=tocxml&d=HANSARD-10-17452"

fragment_download_url = "https://hansardpublic.parliament.sa.gov.au/_layouts/15/Hansard/DownloadHansardFile.ashx?t=fragment&d=HANSARD-11-24737"
# From own server it sends the file as content-type text/xml, 
# pipe_download_url = "http://sa.pipeproject.info/xmldata/upper/HANSARD-10-17452.xml"

fF_user_agent_string = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.90 Safari/537.36"

$debug = TRUE
$csvoutput = FALSE
$sqloutput = FALSE

module JSONDownloader

  # The URLs to access the API... 
  @json_download_year_url = "https://hansardpublic.parliament.sa.gov.au/_vti_bin/Hansard/HansardData.svc/GetYearlyEvents/"

  @json_download_toc_url = "https://hansardpublic.parliament.sa.gov.au/_vti_bin/Hansard/HansardData.svc/GetByDate"

  def JSONDownloader.download_all_fragments(year) 
  
    #Annual Index is a special case - different API URL  
    annual_index_filename = download_annual_index(year)

    get_toc_hash(annual_index_filename) do |toc_saph_filename| 

      # then we read and load the JSON
      # and request each fragment for each day... 
      download_toc(toc_saph_filename) 

      # then get the hash of fragments from each TOC file... 

        # and download each one. 

    end


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

JSONDownloader.download_all_fragments(2016) 

#  `curl --silent --output data/representatives.csv "https://api.morph.io/alisonkeen/SA_members_for_OA_parser/data.csv?key=#{conf.morph_api_key}&query=select%20*%20from%20'data'"`
#  `curl --silent --output data/senators.csv "https://api.morph.io/alisonkeen/SA_senators_for_OA_parser/data.csv?key=#{conf.morph_api_key}&query=select%20*%20from%20'data'"`

# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})

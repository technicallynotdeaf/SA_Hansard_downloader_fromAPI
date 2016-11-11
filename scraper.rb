
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
require 'json'
require 'fileutils'

# from Hansard server content-type is text/html, attachment is xml

$debug = TRUE
$csvoutput = FALSE
$sqloutput = FALSE

module JSONDownloader

  # The URLs to access the API... 
  @jsonDownloadYearURL = "https://hansardpublic.parliament.sa.gov.au/_vti_bin/Hansard/HansardData.svc/GetYearlyEvents/"

  @jsonDownloadTocUrl = "https://hansardpublic.parliament.sa.gov.au/_vti_bin/Hansard/HansardData.svc/GetByDate"
 
  # @jsonDownloadTocUrl = "http://pipeproject.info/date/GetByDate"


  def JSONDownloader.downloadAllFragments(year) 
  
    #Annual Index is a special case - different API URL  
    annualIndexFilename = downloadAnnualIndex(year)

    downloadEachToc(annualIndexFilename) 


      # then we read and load the JSON
      # and request each fragment for each day... 
#       downloadToc(toc_saphFilename) 

      # then get the hash of fragments from each TOC file... 

        # and download each one. 

    if $debug

      puts "\nTesting TOC download URL... ======== \n"
      `curl --output HANSARD_test_toc  "https://hansardpublic.parliament.sa.gov.au/_vti_bin/Hansard/HansardData.svc/GetByDate" -H "Content-Type: application/json; charset=UTF-8" -H "Accept: */*" --data-binary "{""DocumentId"" : ""HANSARD-11-22597""}"`

      puts "\nTesting Fragment download URL... ======== \n" 
      `curl --output HANSARD_test_fragment "https://hansardpublic.parliament.sa.gov.au/_vti_bin/Hansard/HansardData.svc/GetFragmentHtml" -H "Content-Type: application/json; charset=UTF-8" -H "Accept: application/json, text/javascript, */*; q=0.01" -H "X-Requested-With: XMLHttpRequest" --data-binary "{""DocumentId"" : ""HANSARD-11-22542""}"`
      `cat HANSARD_test_fragment`

    end # end API example runs

  end

  # "saphFilename" will be soemthing like "HANSARD-10-2343" with no
  # file extension. 
  def JSONDownloader.downloadToc(saphFilename, transcriptDate)

    puts "Filename requested: " + saphFilename if $debug

    curlFlags = " -f " # Doesn't save HTML error pages instead of file
    requestHeaders = " -H \"Content-Type: application/json; charset=UTF-8\" -H \"Accept: */*\" --request POST --data-binary \"{\"\"DocumentId\"\" : \"\"#{saphFilename}\"\"}\" "

    urlToLoad = @jsonDownloadTocUrl  

    if !File.exist?( "downloaded/#{transcriptDate}" ) and
      !File.directory?( "downloaded/#{transcriptDate}" )

      FileUtils::mkdir_p "downloaded/#{transcriptDate}"
    end #end if

    tocFilename = "downloaded/#{transcriptDate}/#{saphFilename}_hansard.json"

    # First we download the table of contents    
    fullCMD = "curl --output #{tocFilename} #{curlFlags} #{requestHeaders} #{urlToLoad}"
    puts "downloading TOC file as: #{fullCMD}" if $debug 

    returnval = `curl --output #{tocFilename} #{curlFlags} #{requestHeaders} #{urlToLoad}`

    puts "Return val: #{returnval.to_s}"

    # Then we turn it into XML... 
 
    tocFilename # The output of the method. ruby doesn't use 'return'
  end

  
  # read horrible JSON file and get toc filenames
  def JSONDownloader.downloadEachToc(annualIndexFilename)

    puts "Parsing annual index #{annualIndexFilename}" if $debug
    rawJSON = File.read(annualIndexFilename)
    loadedJSON = JSON.load rawJSON # Why is this returning a String!?
    parsedJSON = JSON.load loadedJSON #will trying twice help?

    parsedJSON.each do |event| # for-each-date
      puts event.keys if $debug
      record_date =  event['date'].to_s

      puts "Available for..." + record_date if $debug

      event['Events'].each do |record| # for each transcript on date
        puts "\nEvent: " + record.to_s if $debug
        saphFilename = record['TocDocId'].to_s
   

        if saphFilename.empty?
          puts 'Have you got the right key? saph filename not found.'
          puts " Keys in record: "
          puts record.keys
          puts " -- end record of transcript -- "
        else
#          tocFilename = JSONDownloader.downloadToc( saphFilename , record_date )
#           puts "Downloaded: " + tocFilename if $debug
        end


      end # end for-each-transcript-on-date block
      
    end # end for-each-date block

  end

  # Puts the raw, no-line-breaks JSON into a file and
  # returns the file name.
  def JSONDownloader.downloadAnnualIndex(year)

    urlToLoad = @jsonDownloadYearURL + year.to_s
    filename = "downloaded/#{year.to_s}_hansard.json"
    
    puts "downloading file"   
    `curl --output #{filename} "#{urlToLoad}"`
 
    filename # The output of the method. ruby doesn't use 'return'
  end




end #end JSONDownloader class

JSONDownloader.downloadAllFragments(2016) if $debug



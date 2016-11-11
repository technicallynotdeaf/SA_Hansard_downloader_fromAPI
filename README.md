<<<<<<< HEAD
The beginnings of a scraper to read Hansard dates

Scraper is built using Poltergeist / Capybara due to heavy AJAX insertion of content that doesn't appear when scraped with Mechanize

Notes to self: 
When debugging/running scraper on own ubuntu system, prerequisites are 
[code]
sudo gem install poltergeist
[/code]
Then go to the PhantomJS website and manually wget the PhantomJS build .tar.bz2 because the Ubuntu package is built against the wrong graphics toolkit and crashes on load. 

This is a scraper that runs on [Morph](https://morph.io). To get started [see the documentation](https://morph.io/documentation)
=======
# SA_Hansard_downloader_fromAPI
Just discovered the SA Hansard has an API. Rewriting download code to see how easy it is to use... 
>>>>>>> origin/master

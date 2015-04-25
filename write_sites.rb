require 'httparty'
require 'json'
require 'pry'

$WHITELIST_SITES = []

(0..19).each do |num|
  extraParam = "&kimpath2=category;#{num}"
  response = HTTParty.get("https://www.kimonolabs.com/api/ondemand/byeacp5e?apikey=h9KtzbdFexV610fmIa7O25kVhxfCdzG1#{extraParam}")
  body = response.body
  bodyJSON = JSON.parse body
  arr = bodyJSON["results"]["collection1"]
  arr.each do |result|
    url = result["site"]["text"]
    url.downcase!
    url[0..6] if url.start_with? "http://"
    url[0..7] if url.start_with? "https://"
    $WHITELIST_SITES.push url
  end
  puts "finished #{num}"
end

puts "done!"

File.open("whitelist_sites.json", 'w') { |f|
  text = JSON.generate $WHITELIST_SITES
  f.write text
}
require 'pry'
require 'nyny'
require 'mongo'
require 'httparty'
include Mongo

client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => "discover")
$entry_col = client['entries']
$feedback_col = client['feedback']

$WHITELIST_SITES = []

(0..19).each do |num|
  extraParam = "&kimpath2=category;#{num}"
  response = HTTParty.get("https://www.kimonolabs.com/api/byeacp5e?apikey=h9KtzbdFexV610fmIa7O25kVhxfCdzG1#{extraParam}")
  body = response.body
  bodyJSON = JSON.parse body
  arr = bodyJSON["results"]["collection1"]
  arr.each do |result|
    url = result["site"]["text"]
    url.downcase!
    $WHITELIST_SITES.push url
  end
end

puts $WHITELIST_SITES

class App < NYNY::App
  get '/' do
    'wassup cuh'
  end

  post '/data_post' do
    headers['Access-Control-Allow-Origin'] = 'chrome-extension://bklnejfjjbjnokioghhknnngghgfmhjc'

    filename = (0...8).map { (65 + rand(26)).chr }.join
    filename << ".json"
    requestData = request.body.read
    data = JSON.parse requestData
    user_id = data["user_id"]

    data.each do |key, val|
      next if key == "user_id"
      currentQuery = $entry_col.find({:user_id => user_id, :url => key}).limit(1)
      currCount = currentQuery.count

      if currCount > 0
        currentQuery.update_one("$inc" => {:time => val["time"], :visits => val["visits"]})
      else
        $entry_col.insert_one ({
          :user_id => user_id, 
          :time => val["time"], 
          :url => key,
          :visits => val["visits"],
          :title => val["title"]
        })
      end
    end

    puts "user_id: #{user_id}"

    if !File.directory? user_id
      # make directory for user_id
      Dir.mkdir user_id
    end

    File.open("#{user_id}/#{filename}", 'w') { |f|
      f.write(requestData)
    }

    puts "wrote to file #{filename}"
    puts requestData

    'got it!'
  end

  post '/feedback' do
    headers['Access-Control-Allow-Origin'] = 'chrome-extension://bklnejfjjbjnokioghhknnngghgfmhjc'
    params.delete "_id"
    currentQuery = $feedback_col.find({:user_id => params["user_id"], :url => params["url"], :question => params["question"]}).limit(1)
    currCount = currentQuery.count

    if currCount > 0
      updateHash = { :answer => params["answer"], :visits => params["visits"], :time => params["time"]}
      currentQuery.update_one('$set' => updateHash)
    else
      $feedback_col.insert_one (params)
    end
    'got it cuh'
  end

  def url_in_whitelist

  def filter_data results
    filteredData = []
    data.each do |entry|



    filteredData
  end

  end

  get '/suggested_sites/:user_id' do
    user_id = params["user_id"]
    headers['Access-Control-Allow-Origin'] = 'chrome-extension://bklnejfjjbjnokioghhknnngghgfmhjc'

    data = $entry_col.find(:user_id => user_id)

    if data.count == 0
      JSON.generate []
    else
      filteredData = []

      data.each do |entry|
        filteredData.push(entry) if entry["visits"] < 10
      end

      # sort by time
      sortedData = filteredData.sort_by! {|value| value["time"]}

      if sortedData.length < 10
        JSON.generate sortedData
      else
        JSON.generate sortedData.slice((-10..-1))
      end
    end
  end
end

App.run!
require 'pry'
require 'nyny'
require 'mongo'
include Mongo

client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => "discover")
$col = client['entries']

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
      currentQuery = $col.find({:user_id => user_id, :url => key}).limit(1)
      currCount = currentQuery.count

      if currCount > 0
        currentQuery.update_one("$inc" => {:time => val["time"], :visits => val["visits"]})
      else
        $col.insert_one ({
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
  end

  get '/suggested_sites/:user_id' do
    user_id = params["user_id"]
    headers['Access-Control-Allow-Origin'] = 'chrome-extension://bklnejfjjbjnokioghhknnngghgfmhjc'

    data = $col.find(:user_id => user_id)

    if data.count == 0
      JSON.generate []
    else
      filteredData = []

      data.each do |entry|
        filteredData.push(entry) if entry["visits"] < 10
      end

      # sort by time
      sortedData = filteredData.sort_by! {|value| value["time"]}

      JSON.generate sortedData.slice((-10..-1))
    end
  end
end

App.run!
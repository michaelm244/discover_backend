require 'pry'
require 'nyny'

class App < NYNY::App
  get '/' do
    'wassup cuh'
  end

  post '/data_post' do
    filename = (0...8).map { (65 + rand(26)).chr }.join
    filename << ".json"
    requestData = request.body.read
    data = JSON.parse requestData
    user_id = data["user_id"]

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

    headers['Access-Control-Allow-Origin'] = 'chrome-extension://bklnejfjjbjnokioghhknnngghgfmhjc'
  end

  get '/suggested_sites/:user_id' do
    user_id = params["user_id"]
    headers['Access-Control-Allow-Origin'] = 'chrome-extension://bklnejfjjbjnokioghhknnngghgfmhjc'
    files = Dir["#{user_id}/*"]
    return 'Invalid user id' if files.size == 0

    data = {}
    files.each do |filename|
      currFile = File.open "#{user_id}/#{filename}", "r"
      currData = JSON.parse currFile.read()
      currData.each do |key, value|
        currentValues = data[key] || {"time" => 0, "visits" => 0}
        data[key]["time"] += value["time"]
        data[key]["visits"] += value["visits"]
      end
    end

    # filter out websites with more than 10 visits
    data.delete_if {|key, value|
      value["visits"] > 10
    }

    binding.pry

  end
end

App.run!
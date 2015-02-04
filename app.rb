require 'nyny'
require 'json'
require 'debugger'

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

    debugger
    if !File.directory? user_id
      # make directory for user_id
      Dir.mkdir user_id
    end

    File.open("#{user_id}/#{filename}", 'w') { |f|
      f.write(requestData)
    }

    puts "wrote to file #{filename}"
    puts requestData

    headers['Access-Control-Allow-Origin'] = 'chrome-extension://oophbkhofmknaajfheijgcfbpcehphaj'
  end
end

App.run!
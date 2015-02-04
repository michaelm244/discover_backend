require 'nyny'
require 'json'

class App < NYNY::App
  get '/' do
    'wassup cuh'
  end

  post '/data_post' do
    filename = (0...8).map { (65 + rand(26)).chr }.join
    filename << ".json"
    data = JSON.parse request.body.read
    user_id = data["user_id"]

    puts "user_id: #{user_id}"

    if !File.directory? user_id
      # make directory for user_id
      Dir.mkdir user_id
    end

    File.open("#{user_id}/#{filename}", 'w') { |f|
      f.write(request.body.read)
    }

    puts "wrote to file #{filename}"
    puts request.body.read

    headers['Access-Control-Allow-Origin'] = 'chrome-extension://oophbkhofmknaajfheijgcfbpcehphaj'
  end
end

App.run!
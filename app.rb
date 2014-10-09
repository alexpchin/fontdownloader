require 'sinatra/base'
require 'uri'
require 'date'
require 'net/http'
require 'net/ftp'
require 'open-uri'
require './lib/downloadfonts'

class App < Sinatra::Base
  set :root, File.dirname(__FILE__)
  include Download

  get '/' do
    @css = File.open("#{File.dirname(__FILE__)}/public/assets/font-face.css", "rb").read
    haml :index
  end

  post '/' do
    target_dir_name = Download::run params[:url]
    if target_dir_name
      redirect "/uploads/#{target_dir_name}/#{target_dir_name}.zip"
    else
      redirect "/"
    end
  end

end
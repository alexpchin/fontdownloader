require 'sinatra/base'
require 'sinatra/reloader'
require 'uri'
require 'date'
require 'net/http'
require 'net/ftp'
require 'open-uri'
require './lib/downloadfonts'

class FontDownloader < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
  end

  include Download

  get '/' do
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
require 'sinatra'
require 'uri'
require 'net/http'
require 'date'
require 'net/ftp'
require 'open-uri'
require './lib/downloadfonts'

class FontDownloader < Sinatra::Base
  include Download

  get '/' do
    haml :index
  end

  post '/' do
    target_dir_name = Download::run params[:url]
    redirect "/uploads/#{target_dir_name}/#{target_dir_name}.zip"
  end

end
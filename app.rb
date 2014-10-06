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
    Download::run params[:url]
  end

end
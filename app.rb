require 'sinatra'
require 'uri'
require 'net/http'
require 'date'
require 'net/ftp'
require 'open-uri'
require './lib/downloadfonts'

class FontDownloader < Sinatra::Base

  get '/' do
    haml :index
  end

  post '/' do
    run params[:url]
  end

end
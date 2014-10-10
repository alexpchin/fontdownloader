require 'sinatra/base'
require 'uri' 
require 'date' 
require 'net/http' 
require 'net/ftp' 
require 'open-uri' 
require './lib/downloadfonts'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

module FontDownloader
  class App < Sinatra::Base
    enable :sessions
    register Sinatra::Flash
    helpers Sinatra::RedirectWithFlash

    set :root, File.expand_path("../../", __FILE__)
    include Download

    get '/' do
      @css = File.open(settings.root + "/public/assets/font-face.css", "rb").read
      @woff = File.open(settings.root + "/public/assets/woff.css", "rb").read
      haml :index
    end

    post '/' do
      target_dir_name = Download::run params[:url]
      flash[:notice] = 'The post was successfully created'
      redirect "/"
      # if target_dir_name
      #   redirect "/uploads/#{target_dir_name}/#{target_dir_name}.zip"
      # else
      #   redirect "/"
      # end
    end

  end
end
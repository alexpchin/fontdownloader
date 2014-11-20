module FontDownloader
  class App < Sinatra::Base
    register Sinatra::Flash
    helpers Sinatra::RedirectWithFlash
    
    configure do
      # Set the views location
      set :views, File.join(FontDownloader::App.root, "views")

      # Set the root path
      set :root, File.expand_path("../../", __FILE__)

      # Setup assets
      set :assets, (Sprockets::Environment.new { |env|
        env.append_path(settings.root + "/public/assets/images")
        env.append_path(settings.root + "/public/assets/javascripts")
        env.append_path(settings.root + "/public/assets/stylesheets")

        # Compress everything in production
        if ENV["RACK_ENV"] == "production"
          env.js_compressor  = YUI::JavaScriptCompressor.new
          env.css_compressor = YUI::CssCompressor.new
        end
      })

      # Required for flash
      enable :sessions 
    end

    get '/' do
      @css = File.open(settings.root + "/public/assets/font-face.css", "rb").read
      @woff = File.open(settings.root + "/public/assets/woff.css", "rb").read
      haml :index
    end

    post '/' do
      begin
        download = Download.new(params[:url])
        if !download.fonts.empty?

          tempfile    = Tempfile.new("foo")
          Zip::OutputStream.open(tempfile.path) do |zos|
            download.fonts.each do |font|
puts font.url # For terminal
              if !font.datastring.empty?
                zos.put_next_entry("fonts/#{font.filename}")
                zos.write font.datastring
              end
            end
          end

          # http://www.rubydoc.info/github/sinatra/sinatra/Sinatra/Helpers:send_file
          send_file tempfile.path, 
            :type => 'application/zip', 
            :disposition => 'attachment', 
            :filename => "fonts.zip"
        end
      ensure
        tempfile.close if tempfile
      end

      flash[:notice] = "A problem has occured or there were no fonts."
      redirect "/"
    end

    get "/assets/app.js" do
      content_type("application/javascript")
      settings.assets["app.js"]
    end

    get "/assets/app.css" do
      content_type("text/css")
      settings.assets["app.css"]
    end

    %w{jpg png ico}.each do |format|
      get "/:image.#{format}" do |image|
        content_type("image/#{format}")
        settings.assets["#{image}.#{format}"]
      end
    end

  end
end
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
        # Create a directory name for this download
        target_dir_name = Date.today.strftime('%y%m%d')

        # Create securehex to add to this download
        hex = SecureRandom.hex

        # Create unique(ish) directory name using target_dir_name and hex
        target_dir_name = "#{target_dir_name}-#{hex}"

        t = Tempfile.new(target_dir_name)

        Zip::OutputStream.open(t.path) do |z|
          Download::run(t.path)
        end

        # Send tempfile to user
        send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => "List.zip"
      
      ensure
        t.close
        t.unlink # Delete the tempfile
      end

      flash[:notice] = "Thanks for using Font Downloader."
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
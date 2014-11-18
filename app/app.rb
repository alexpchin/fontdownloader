module FontDownloader
  class App < Sinatra::Base
    register Sinatra::Flash
    helpers Sinatra::RedirectWithFlash
    helpers Sinatra::Xsendfile
    
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

    configure :production do
      # Replace Sinatra's send_file with x_send_file
      Sinatra::Xsendfile.replace_send_file!

      # Set x_send_file header (default: X-SendFile)
      set :xsf_header, 'X-Accel-Redirect'
    end

    get '/' do
      @css = File.open(settings.root + "/public/assets/font-face.css", "rb").read
      @woff = File.open(settings.root + "/public/assets/woff.css", "rb").read
      haml :index
    end

    post '/' do
      begin
    
        download = Download.new(params[:url])

        # Add fontfiles to tempfile
        tempfile    = Tempfile.new("foo")
        Zip::OutputStream.open(tempfile.path) do |z|

          download.fonts.each do |font|
puts "Filename: #{font.filename}"

            # Create a new entry with the name of the font
            z.put_next_entry("fonts/#{font.filename}")

            # Create a tempfile and read the contents
            font = font.create_tempfile
puts "Tempfile: #{font}"
puts "File exists? #{File.exists?(font)}"

            # Read tempfile and print into zip
            z.print IO.read(font.path)

          end
        end

        # Send tempfile to user
        send_file tempfile.path, 
          :type => 'application/zip', 
          :disposition => 'attachment', 
          :filename => "fonts.zip"

      ensure
        tempfile.close if tempfile
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
require 'sprockets'

module FontDownloader
  class Assets < Sinatra::Base
    configure do
      set :root, File.expand_path("../../", __FILE__)
      set :assets, (Sprockets::Environment.new { |env|
        env.append_path(settings.root + "/public/assets/images")
        env.append_path(settings.root + "/public/assets/javascripts")
        env.append_path(settings.root + "/public/assets/stylesheets")

        # compress everything in production
        if ENV["RACK_ENV"] == "production"
          env.js_compressor  = YUI::JavaScriptCompressor.new
          env.css_compressor = YUI::CssCompressor.new
        end
      })
    end

    # Will be prefixed by assets
    get "/app.js" do
      content_type("application/javascript")
      settings.assets["app.js"]
    end

    # Will be prefixed by assets
    get "/app.css" do
      content_type("text/css")
      settings.assets["app.css"]
    end

    %w{jpg png ico}.each do |format|
      get "/assets/:image.#{format}" do |image|
        content_type("image/#{format}")
        settings.assets["#{image}.#{format}"]
      end
    end
  end
end
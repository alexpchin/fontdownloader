module FontDownloader

  class Download
    attr_reader :url, :directory, :stylesheets, :font_urls, :fonts

    def initialize(url)
      @url         = url
      @directory   = create_directory
      @stylesheets = gather_stylesheets
      @font_urls   = gather_font_urls
      @fonts       = gather_fonts
    end

    def target_dir_name
      "#{Date.today.strftime('%y%m%d')}-#{SecureRandom.hex}"
    end

    def create_directory
      Tempfile.new(target_dir_name)
    end

    def gather_stylesheets
      StylesheetUrls.new(url).stylesheets
    end

    def gather_font_urls
      FontUrls.new(url, stylesheets).font_urls
    end

    def gather_fonts
      # font_urls[0...1].map { |url| Font.new(url, directory.path) }
      font_urls.map { |url| Font.new(url, directory.path) }
    end
    
  end
end
module FontDownloader

  class Download
    attr_reader :url, :stylesheets, :font_urls, :fonts

    def initialize(url)
      @url         = get_url(url)     #String
      @stylesheets = get_stylesheets  #Array of strings
      @font_urls   = get_font_urls    #Array of strings
      @fonts       = get_fonts        #Array of Font objects
    end

    def get_url(url)
      url = url.strip
      if url.nil? || url.empty?
        raise ArgumentError, "Incorrectly formatted url given." 
      else
        url
      end
    end

    def get_stylesheets
      StylesheetUrls.new(url).stylesheets
    end

    def get_font_urls
      FontUrls.new(url, stylesheets).font_urls
    end

    def get_fonts
      font_urls.map { |font_url| Font.new(font_url) }.uniq
    end
  end

end
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
      if url.nil? || url.empty?
        raise ArgumentError, "Incorrectly formatted url given." 
      else
        url.strip
      end
    end

    def get_stylesheets
      StylesheetUrls.new(url).stylesheets rescue []
    end

    def get_font_urls
      FontUrls.new(url, stylesheets).font_urls rescue []
    end

    def get_fonts
      font_urls.map do |font_url| 
        Font.new(font_url) rescue nil 
      end.compact.uniq
    end
  end

end
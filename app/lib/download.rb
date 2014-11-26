module FontDownloader

  class Download
    attr_reader :url, :stylesheets, :font_urls, :fonts

    def initialize(url)
      @url         = get_url(url)     #String
      @stylesheets = get_stylesheets  #Array of strings
      @font_urls   = get_font_urls    #Array of strings
      @fonts       = get_fonts        #Array of Font objects
    end

    def resolve_redirects(url)
      response = fetch_response(url, method: :head)
      if response
        response.to_hash[:url].to_s
      else
        return nil
      end
    end

    def fetch_response(url, method: :get)
      conn = Faraday.new do |b|
        b.use FaradayMiddleware::FollowRedirects;
        b.adapter :net_http
      end
      return conn.send method, url
    rescue Faraday::Error, Faraday::Error::ConnectionFailed => e
      return nil
    end

    def smart_add_url_protocol(url)
      if url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//]
        url
      else
        "http://#{url}"
      end
    end

    def get_url(url)
      if url.nil? || url.empty?
        raise ArgumentError, "Incorrectly formatted url given." 
      else
        url = smart_add_url_protocol(url.strip)
        url = resolve_redirects(url)
puts "Searching #{url} for fonts."
        url
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
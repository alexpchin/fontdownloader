module FontDownloader

  class FontUrls
    attr_reader :url, :stylesheets, :font_urls

    def initialize(url, stylesheets)
      @url         = url
      @stylesheets = stylesheets
      @font_urls   = get_font_urls
    end

    def get_font_urls
      stylesheets.map do |stylesheet| 

        css = return_css(stylesheet)
        
        # Grab all @font-face declarations
        font_faces = css.scan(/@font-face[^}]*\}/)
        raise ArgumentError, "There are no fonts." if font_faces.nil?

        font_urls = create_array_of_font_urls(font_faces).flatten
        raise ArgumentError, "There are no fonts." if font_faces.nil?

        font_urls.uniq! if font_urls
        font_urls.map { |file| UrlResolver.resolve(url, file) }    

      end.flatten
    end

    def return_css(stylesheet)
      # Resolve long url for stylesheet, //, http:// or relative
      link = UrlResolver.resolve(url, stylesheet)

      begin
        # Open stylesheet using Nokogiri & beautify/split css for regex
        css = beautify_css(Nokogiri::HTML(open(link)).to_s)

      rescue OpenURI::HTTPError => e
        raise e
      end
    end

    def beautify_css(string)
      string.split(';').join('; ')
    end

    def create_array_of_font_urls(font_faces)
      font_faces.map do |font|

        # Anything between the brackets
        array = font.scan(/(?:\(['|"]?)(.*?)(?:['|"]?\))/)

        array.flatten.map { |f| f if f[/.eot|.woff|.ttf|.svg/] }.compact if array.any?
      end
    end
  end

end
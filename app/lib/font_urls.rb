module FontDownloader

  class FontUrls
    attr_reader :url, :stylesheets, :font_urls

    def initialize(url, stylesheets)
      @url         = url
      @stylesheets = stylesheets
      @font_urls   = get_font_urls
    end

    def get_font_urls
      stylesheets.map do |stylesheet_url| 

        css        = get_css(stylesheet_url)
        font_faces = get_font_faces(css)
        font_urls  = create_array_of_font_urls(font_faces).flatten
  
        font_urls.map { |href| URI.join(stylesheet_url, href).to_s }

      end.flatten
    end

    def get_font_faces(css)
      css.scan(/@font-face[^}]*\}/)
    end

    def get_css(stylesheet)
      # Resolve long url for stylesheet, //, http:// or relative
      link = URI.join(url, stylesheet).to_s

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

        # Anything between the url brackets
        array = font.scan(/(?:\(['|"]?)(.*?)(?:['|"]?\))/)

        array.flatten.map { |f| f if f[/.eot|.woff|.ttf|.svg/] }.compact if array.any?
      end.uniq
    end
  end

end
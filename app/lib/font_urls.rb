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
        create_array_of_font_urls(font_faces, stylesheet_url).flatten
      end.flatten
    end

    def get_css(stylesheet)
      # Resolve long url for stylesheet, //, http:// or relative
      link = UrlResolver.resolve(url, stylesheet)
puts link # For terminal

      begin
        # Open stylesheet using Nokogiri & beautify/split css for regex
        css = beautify_css(Nokogiri::HTML(open(link)).to_s)
      rescue OpenURI::HTTPError => e
        raise e
      end
    end

    def get_font_faces(css)
      # Find font faces
      css.scan(/@font-face[^}]*\}/)
    end

    def get_font_url(font)
      # Anything between the url brackets
      font.scan(/(?:\(['|"]?)(.*?)(?:['|"]?\))/).flatten
    end

    def beautify_css(string)
      string.split(';').join('; ')
    end

    def create_array_of_font_urls(font_faces, stylesheet_url)
      font_faces.map do |font_face|
        # Look in the font_face string and find the font url
        get_font_url(font_face).map do |href|

          # Resolve relative paths and remove suffix, e.g. ?#iefix
          # If it is a font, not format('embedded-opentype') etc
          UrlResolver.resolve(stylesheet_url, href)[/[^\?\#!]+/] if href[/.eot|.woff|.ttf|.svg/]
        end
      end.flatten.compact.uniq
    end
  end

end
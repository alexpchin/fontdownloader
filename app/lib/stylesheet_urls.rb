module FontDownloader

  class StylesheetUrls
    attr_reader :url, :stylesheets

    def initialize(url)
      @url = url
      @stylesheets = get_stylesheets
    end

    def get_stylesheets
      get_stylesheets_from_head(parse_head)
    end

    def parse_head
      Nokogiri::HTML(open(url)).xpath("/html/head")
    end

    def get_stylesheets_from_head(doc)
      doc.xpath('//link[@rel="stylesheet"]').map { |link| link['href'] }.uniq
    end
  end

end
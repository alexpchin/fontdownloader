module FontDownloader

  class StylesheetUrls
    attr_reader :url, :stylesheets

    def initialize(url)
      @url = url
      @stylesheets = extract
    end

    def extract
      doc = extract_head
      extract_stylesheets_from_head(doc)
    end

    def extract_head
      Nokogiri::HTML(open(url)).xpath("/html/head")
    end

    def extract_stylesheets_from_head(doc)
      doc.xpath('//link[@rel="stylesheet"]').map { |link| link['href'] }
    end

  end

end
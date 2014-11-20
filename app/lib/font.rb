module FontDownloader

  class Font
    attr_reader :url, :filename, :fontname, :extension, :basename, :datastring

    def initialize(url)
      @url        = get_url(url)
      @fontname   = get_fontname
      @suffix     = get_suffix
      @filename   = get_filename
      @extension  = get_extension 
      # @datastring = download
    end

    def get_url(url)
      url = url.strip
      if url.nil? || url.empty?
        raise ArgumentError, "Incorrectly formatted url given." 
      else
        url
      end
    end

    # Includes things after the extension name ?#iefix
    def get_fontname
      File.basename(url)
    end

    def get_suffix
      fontname[/\?!\?|#(.*)/]
    end

    def get_filename
      File.basename(url)[/(?:(?!\?|#).)*/]
    end

    def get_extension
      File.extname(url)
    end

    # Used to use File.exists? but as only returning string now not checking dir.
    def download
      uri = URI.parse(url)
      case uri.scheme.downcase
      when /http|https/
        http_download_uri(uri)
      when /ftp/
        ftp_download_uri(uri)
      else
        raise ArgumentError, "Unsupported URI scheme for resource #{filename}"
      end
    end

    def http_download_uri(uri)
      begin
        # open(uri.to_s)
        open(url) { |f| f.read }

        # # Creates a new Net::HTTP object without opening a TCP connection or HTTP session.
        # http_object = Net::HTTP.new(uri.host, uri.port)
        # http_object.use_ssl = true if uri.scheme == 'https'

        # # Creates a new Net::HTTP object, then additionally opens the TCP connection and HTTP session.
        # http_object.start do |http|
        #   http.read_timeout = 500

        # end

        # http_object.start do |http|
        #   # Net::HTTP generalassemb.ly:443 open=false
        #   request = Net::HTTP::Get.new uri.request_uri
        #   http.read_timeout = 500
          
        #   # Net::HTTPNotFound 404 Not Found readbody=true
        #   http.request request do |response|
        #     # response.read_body
        #     response
        #   end
        # end
      rescue Exception => e
        raise e
      end
    end

    def ftp_download_uri(uri)
      puts "Starting FTP download for: " + uri.to_s
      begin
        Net::FTP.open(uri.host) do |ftp|
          ftp.login
          ftp.chdir(dirpath)
          ftp.getbinaryfile(basename)
        end
      rescue Exception => e
        puts "=> Exception: '#{e}'. Skipping download."
        return
      end
      puts "Stored download as " + filename + "."
    end
  end

end
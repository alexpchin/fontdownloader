module FontDownloader

  class Font
    attr_reader :url, :filename, :fontname, :extension, :basename, :datastring

    def initialize(url)
      @url        = get_url(url)
      @filename   = get_filename
      @extension  = get_extension 
      @datastring = download
    end

    def get_url(url)
      url = url.strip
      if url.nil? || url.empty?
        raise ArgumentError, "Incorrectly formatted url given." 
      else
        url
      end
    end

    def get_filename
      File.basename(url)[/(?:(?!\?|#).)*/]
    end

    def get_extension
      File.extname(url)
    end

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
        open(url) { |f| f.read }
      rescue Exception => e
        puts "=> Exception: '#{e}'. Skipping download."
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
module Remote 
  class LocalResource

    attr_reader :uri, :tmp_folder
    
    def initialize(uri)
      @uri = uri
      @tmp_folder = tmp_folder
    end

    def file
      @file ||= Tempfile.new(tmp_filename, tmp_folder, encoding: encoding).tap do |f|
        io.rewind
        f.write(io.read)
        f.close
      end
    end
    
    def io
      @io ||= uri.open
    end
    
    def encoding
      io.rewind
      io.read.encoding
    end
    
    def tmp_filename
      [
        Pathname.new(uri.path).basename,
        Pathname.new(uri.path).extname
      ]
    end
    
    def tmp_folder
      @tmp_folder
    end

  end
end
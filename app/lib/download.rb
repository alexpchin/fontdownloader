module FontDownloader

  class Download
    attr_reader :url, :tmp_folder

    def initialize(url, tmp_folder)
      @url        = url
      @tmp_folder = tmp_folder
    end

    def run
      # download_resources(input_filenames)
    end
    
  end
end
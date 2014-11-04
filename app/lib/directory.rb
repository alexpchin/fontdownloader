module FontDownloader

  class Directory
    attr_reader :path, :name

    def initialize
      @name = set_name
      @path = set_location
      create
    end

    def set_name
      "#{Date.today.strftime('%y%m%d')}-#{SecureRandom.hex}"
    end

    def set_location
      File.expand_path("../../../public/uploads/#{name}", __FILE__)
    end

    def create
      unless File.exists?(path)
        Dir.mkdir(path)
      else
        puts "Skipping creating directory #{path}. It already exists."
      end
    end

    def destroy
      FileUtils.remove_dir(path)
    end

  end

end
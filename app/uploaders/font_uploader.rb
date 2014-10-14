class FontUploader < CarrierWave::Uploader::Base
  storage :fog
end
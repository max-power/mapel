require 'mapel/version'
require 'mapel/geometry'
require 'mapel/engine'
require 'mapel/engine/image_magick'

def Mapel(source)
  Mapel.render(source)
end

module Mapel
  extend SingleForwardable
  delegate [:info, :render, :list, :exif] => :engine

  @default_engine = :image_magick
  
  class << self
    attr_accessor :default_engine

    def engine(name = nil)
      Mapel::Engine.const_get(camelize(name || default_engine))
    end
    
    def camelize(word, *args)
      word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    end
  end
end
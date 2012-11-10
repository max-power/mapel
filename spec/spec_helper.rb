require 'minitest/spec'
require 'minitest/autorun'
require 'turn/autorun'

require 'mapel'

def in_folder
  @in_folder ||= "#{File.dirname(__FILE__)}/fixtures"
end

def out_folder
  @out_folder ||= "#{File.dirname(__FILE__)}/output"
end

def logo
  "#{in_folder}/ImageMagick.jpg"
end

def multi_word_file
  "#{in_folder}/multi-word file.jpg"
end

def rotated_image
  "#{in_folder}/rotated-image.jpg"
end

def setup_output_dir
  Dir.mkdir(out_folder) unless File.exists?(out_folder)
end

def remove_output_dir
  if File.exists?(out_folder)
    Dir.glob("#{out_folder}/*") { |f| File.delete(f) }
    Dir.rmdir(out_folder)
  end
end
require 'rubygems'
require 'bacon'

require File.dirname(__FILE__) + '/../lib/mapel'

def in_folder
  @in_folder ||= File.dirname(__FILE__) + '/fixtures'
end

def out_folder
  @out_folder ||= File.dirname(__FILE__) + '/output'
end

def logo
  @logo ||= in_folder + '/ImageMagick.jpg'
end

def multi_word_file
  @multi_word_file ||= in_folder + '/multi-word file.jpg'
end

def setup
  unless File.exists?(out_folder)
    Dir.mkdir(out_folder)
  end
end

def teardown
  if File.exists?(out_folder)
    Dir.glob(out_folder + '/*') { |f| File.delete(f) }
    Dir.rmdir(out_folder)
  end
end

Bacon.summary_on_exit
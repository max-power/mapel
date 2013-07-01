module Mapel
  class Engine
    class ImageMagick < Engine
      module ClassMethods
        def info(source)
          new.with_command("identify", source.inspect).run.to_info_hash
        end

        def exif(source)
          new.with_command("identify -format %[exif:*]", source.inspect).run.to_exif_hash
        end

        def render(source = nil)
          new.with_command("convert", source.nil? ? nil : source.inspect)
        end

        # http://www.imagemagick.org/script/command-line-options.php#list
        # ex: Mapel.list()
        # ex: Mapel.list('Orientation', true)
        # pass false as second argument, if you want an unparsed result
        def list(type = 'list', parse = true)
          new.with_command("convert -list", type).run.to_list(parse)
        end
      end

      extend ClassMethods
      
      # Crops an image to specified dimensions.
      #
      # More information on ImageMagick's crop option:
      #   http://www.imagemagick.org/script/command-line-options.php#crop
      #
      def crop(*args)
        with_command %(-crop "#{Geometry.new(*args).to_s(true)}")
      end

      # Sets the current gravity suggestion to given type.
      #
      # Values for type incule:
      #   NorthWest, North, NorthEast, West, Center, East, SouthWest, South, SouthEast
      #
      # Call `convert -list gravity` to get a complete list of -gravity settings
      # available in your ImageMagick installation.
      #
      # More information on ImageMagick's gravity option:
      #   http://www.imagemagick.org/script/command-line-options.php#gravity
      #
      def gravity(type = :center)
        with_command "-gravity #{type}"
      end
      
      # Grayscales an image
      #
      # More information on ImageMagick's type option:
      #   http://www.imagemagick.org/script/command-line-options.php#type
      #
      def grayscale
        with_command "-type Grayscale"
      end
      
      # Automatically rotates an image with EXIF Orientation.
      # If the EXIF profile was previously stripped, orient will do nothing.
      #
      # More information on ImageMagick's auto-orient option:
      #   http://www.imagemagick.org/script/command-line-options.php#auto-orient
      #
      def orient
        with_command "-auto-orient"
      end
      
      # Sets the quality level of the output image
      #
      # More information on ImageMagick's quality option:
      #   http://www.imagemagick.org/script/command-line-options.php#quality
      #
      def quality(level)
        with_command "-quality #{level}"
      end

      # Resets the virtual canvas meta-data on the image.
      #
      # More information on ImageMagick's repage option:
      #   http://www.imagemagick.org/script/command-line-options.php#repage
      #
      def repage
        with_command "+repage"
      end

      # Rotates in degree an image.
      #
      # More information on ImageMagick's repage option:
      #   http://www.imagemagick.org/script/command-line-options.php#repage
      #
      def rotate(*args)
        with_command %(-rotate "#{Geometry.new(*args)}")
      end

      # Resizes an image to given geometry args.
      #
      # More information on ImageMagick's resize option:
      #   http://www.imagemagick.org/script/command-line-options.php#resize
      #
      def resize(*args)
        with_command %(-resize "#{Geometry.new(*args)}")
      end

      # Resizes and crops an image to dimensions specified in geometry args.
      # Performs resize + crop + repage
      def resize!(*args)
        width, height = Geometry.new(*args).dimensions
        resize("#{width}x#{height}^").crop(width, height).repage
      end

      # Scales an image to given geometry args, which is faster than resizing.
      #
      # More information on ImageMagick's scale option:
      #   http://www.imagemagick.org/script/command-line-options.php#scale
      #
      def scale(*args)
        with_command %(-scale "#{Geometry.new(*args)}")
      end

      # Removes any profiles or comments from the image, including EXIF meta-data.
      def strip
        with_command "-strip"
      end
      
      # Sets the output path.
      def to(path)
        with_command path.inspect
      end

      # Returns a hash of image informations
      def to_info_hash
        return {} if @output.empty?
        meta = @output.split(" ")
        # Count backwards as an image's path may contain a space
        {
          path:       meta[0..-9].join(" "),
          format:     meta[-8],
          dimensions: meta[-7].split("x").map(&:to_i),
          depth:      meta[-5],
          size:       meta[-3]
        }
      end

      # Converts EXIF data into a hash of values.
      def to_exif_hash
        return {} if @output.empty?
        meta = @output.scan(/exif:([^=]+)=([^\n]+)/)
        Hash[meta]
      end
      
      def to_list(parse = true)
        return self unless parse
        @output.split("\n")
      end
    end
  end
end
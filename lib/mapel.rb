def Mapel(source)
  Mapel.render(source)
end

module Mapel

  # Returns basic information on given image.
  def self.info(source, engine = :image_magick)
    Mapel::Engine.const_get(camelize(engine)).info(source)
  end

  # Extracts EXIF data from image.
  def self.exif(source, engine = :image_magick)
    Mapel::Engine.const_get(camelize(engine)).exif(source)
  end

  # Allows chaining rendering commands. After chaining,
  # call .run to perform the transformation.
  #
  # Example:
  #   Mapel.render("image.jpg").resize("50%").to("output.jpg").run
  #
  # Some commands support ImageMagick geometry. For a complete list
  # of geometry options, visit
  #   http://www.imagemagick.org/script/command-line-processing.php#geometry
  #
  def self.render(source, engine = :image_magick)
    Mapel::Engine.const_get(camelize(engine)).render(source)
  end

  # Lists commands supported by the engine.
  def self.list(engine = :image_magick)
    Mapel::Engine.const_get(camelize(engine)).list
  end

  class Engine
    attr_reader :command, :status, :output
    attr_accessor :commands

    def initialize
      @commands = []
    end

    def success?
      @status
    end

    class ImageMagick < Engine
      def self.info(source)
        im = new
        im.commands << "identify"
        im.commands << source.inspect
        im.run.to_info_hash
      end

      def self.exif(source)
        im = new
        im.commands << "identify -format %[exif:*]"
        im.commands << source.inspect
        im.run.to_exif_hash
      end

      def self.render(source = nil)
        im = new
        im.commands << "convert"
        im.commands << source.inspect unless source.nil?
        im
      end

      def self.list(type = nil)
        im = new
        im.commands << "convert -list"
        im.run
      end

      # Crops an image to specified dimensions.
      #
      # More information on ImageMagick's crop option:
      #   http://www.imagemagick.org/script/command-line-options.php#crop
      #
      def crop(*args)
        @commands << %(-crop "#{Geometry.new(*args).to_s(true)}")
        self
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
        @commands << "-gravity #{type}"
        self
      end

      # Resets the virtual canvas meta-data on the image.
      #
      # More information on ImageMagick's repage option:
      #   http://www.imagemagick.org/script/command-line-options.php#repage
      #
      def repage
        @commands << "+repage"
        self
      end

      # Removes any profiles or comments from the image,
      # including EXIF meta-data.
      def strip
        @commands << "-strip"
        self
      end

      # Automatically rotates an image with EXIF Orientation.
      # If the EXIF profile was previously stripped, orient will do nothing.
      #
      # More information on ImageMagick's auto-orient option:
      #   http://www.imagemagick.org/script/command-line-options.php#auto-orient
      #
      def orient
        @commands << "-auto-orient"
        self
      end

      # Resizes an image to given geometry args.
      #
      # More information on ImageMagick's resize option:
      #   http://www.imagemagick.org/script/command-line-options.php#resize
      #
      def resize(*args)
        @commands << %(-resize "#{Geometry.new(*args)}")
        self
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
        @commands << %(-scale "#{Geometry.new(*args)}")
        self
      end

      # Sets the output path.
      def to(path)
        @commands << path.inspect
        self
      end

      # Removes the last command from chain.
      def undo
        @commands.pop
        self
      end

      # Performs the command.
      def run
        @output = `#{to_preview}`
        @status = ($? == 0)
        self
      end

      def to_preview
        @commands.map { |cmd| cmd.respond_to?(:call) ? cmd.call : cmd }.join(" ")
      end

      def to_info_hash
        return {} if @output == ""
        meta = @output.split(" ")

        # Count backwards as an image"s path may contain a space
        {
          :path       => meta[0..-9].join(" "),
          :format     => meta[-8],
          :dimensions => meta[-7].split("x").map {|d| d.to_i},
          :depth      => meta[-5],
          :size       => meta[-3]
        }
      end

      # Converts EXIF data into a hash of values.
      def to_exif_hash
        return {} if @output == ""
        meta = @output.scan(/exif:([^=]+)=([^\n]+)/)
        Hash[meta]
      end
    end
  end

  class Geometry
    attr_accessor :width, :height, :x, :y, :flag

    FLAGS = ["", "%", "<", ">", "!", "@", "^"]

    # Regex parser for geometry strings
    RE = /\A(\d*)(?:x(\d+)?)?([-+]\d+)?([-+]\d+)?([%!<>@\^]?)\Z/

    def initialize(*args)
      if (args.length == 1) && (args.first.kind_of?(String))
        raise(ArgumentError, "Invalid geometry string") unless m = RE.match(args.first)
        args = m.to_a[1..5]
      end
      @width = args[0] ? args[0].to_i.round : 0
      @height = args[1] ? args[1].to_i.round : 0
      raise(ArgumentError, "Width must be >= 0") if @width < 0
      raise(ArgumentError, "Height must be >= 0") if @height < 0
      @x = args[2] ? args[2].to_i : 0
      @y = args[3] ? args[3].to_i : 0
      raise(ArgumentError, "Flags must be in: #{FLAGS.inspect}") if args[4] && !FLAGS.include?(args[4])
      @flag = args[4]
    end

    def dimensions
      [width, height]
    end

    # Convert object to a geometry string
    def to_s(crop = false)
      str = ""
      str << "%g" % @width if @width > 0
      str << "x" if @height > 0
      str << "%g" % @height if @height > 0
      str << "%+d%+d" % [@x, @y] if (@x != 0 || @y != 0 || crop)
      str << @flag if @flag
      str
    end
  end

  # By default, camelize converts strings to UpperCamelCase.
  #
  # camelize will also convert "/" to "::" which is useful for converting paths to namespaces
  #
  # @example
  # "active_record".camelize #=> "ActiveRecord"
  # "active_record/errors".camelize #=> "ActiveRecord::Errors"
  #
  def self.camelize(word, *args)
    word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  end
end

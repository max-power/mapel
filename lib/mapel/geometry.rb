module Mapel
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
end
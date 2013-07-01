module Mapel
  class Geometry
    # Regex parser for geometry strings
    REGEX = /\A(\d*)(?:x(\d+)?)?([-+]\d+)?([-+]\d+)?([-+]\d+)?([%!<>@\^]?)\Z/
    FLAGS = ["", "%", "<", ">", "!", "@", "^"]
    
    attr_accessor :w, :h, :x, :y, :d, :flag

    def initialize(*args)
      if (args.length == 1 && args.first.kind_of?(String))
        raise(ArgumentError, "Invalid geometry string") unless m = REGEX.match(args.first)
        args = m.to_a[1..6]
      end
      @w = args[0].to_i
      @h = args[1].to_i
      @x = args[2].to_i
      @y = args[3].to_i
      raise(ArgumentError, "Width must be >= 0")  if @w < 0
      raise(ArgumentError, "Height must be >= 0") if @h < 0
      @d = args[4].to_i
      raise(ArgumentError, "degrees must be >= 0 and <= 360") if @d < 0 || @d > 360
      raise(ArgumentError, "Flags must be in: #{FLAGS.inspect}") if args[5] && !FLAGS.include?(args[5])
      @flag = args[5]
    end

    def dimensions
      [w, h]
    end

    # Convert object to a geometry string
    def to_s(crop = false)
      str = ""
      str << "%g"  % @w if @w > 0
      str << "x%g" % @h if @h > 0
      str << "%+d%+d" % [@x, @y] if (@x != 0 || @y != 0 || crop)
      str << "%g" % @d if @d > 0
      str << @flag if @flag
      str
    end
  end
end
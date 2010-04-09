=begin
= ogre: Object oriented Graph plot program on Ruby environment
== Programed by Satoshi Ohdachi 
==    ver 0.01 Dec. 2000
=end

include Math
require "color.rb"
require "defs.rb"
include Ogre

=begin
==Class Canvas
  Template class from which all real Canvas Classes are generated.
  All the actions on this canvas is recorded in a file(default = ogre.canvas).
--- Canvas.new(filename='ogre.canvas', defaultstyle=Std_style, defaultfont=Std_font)
      *filename 
        name of the file where actions are recorded.
      *defaultstyle
        Default value of style of graphic objects.
      *defaltfont
        Default value of style of fontname and size.
=end

class Canvas
#
#  Template class to create devices where graphs are drawn.
#           actions onto Canvas are recored in 'ogre.canvas' for debugging
#
attr_accessor :style, :font, :xwidth, :ywidth, :pos1, :pos2

  def initialize(filename='ogre.canvas', defaultstyle=Std_style, defaultfont=Std_font)
#    before_hook

    if filename.kind_of?(IO) then
      @fp = filename
    else
      @fp=File.new(filename, mode="w")
    end
    @style = defaultstyle.dup
    @font = defaultfont.dup

    @defaultstyle = @style.dup
    @defaultfont = @font.dup

    @xwidth  = @ywidth = 100
    @defaultsymsize=0.01
    @dtheta = 0 unless defined?(@dtheta)

    setwhole()
    if block_given? then
      yield(self)
#      after_hook
      closer
    end
  end

  def before_hook
    header()
    set_style(@style)
    set_font(@font)
  end

  def after_hook
  end

  def setwhole
    @fp.printf("set whole\n")
  end

  def setpart( lb, tr ) #[0.0]left bottom, [1.1] top right
    @fp.printf("set part (%f,%f)-(%f,%f)\n", lb[0], lb[1], tr[0], tr[1])
  end

  def line(v1, v2, style = nil)
    set_style(style) unless style == nil
    device_line( trans(v1), trans(v2))
    set_style() unless style == nil
  end

  def multiline(vects, style = nil, closed = false)
    devicev = vects.collect{ |v|
      trans(v)
    }
    if not closed then
      set_style(style) unless style == nil
      device_multiline( devicev, false )
      set_style() unless style == nil
    else
      tempstyle = style.dup
      tempstyle.color = style.background
      set_style( tempstyle )
      device_multiline( devicev, true )
      tempstyle.color = style.color
      set_style ( tempstyle )
      device_multiline( devicev, false )
      set_style()
    end

  end

  def putchar(str, v, justification='L', rotation = 0, font=nil)
    if str != nil then 
      set_font(font) unless font == nil
      nspe = str.scan(/[!^_]/)
      if nspe.size == 0 then
        device_putchar(str, trans(v) , justification, rotation)
      else
        device_putchar2(str, trans(v) , justification, rotation)
      end
      set_font() unless font == nil
    end
  end

  def box(v1, v2, style = nil, closed = false)
    set_style(style) unless style == nil
    nvects = []
    nvects.push( trans(v1) )
    nvects.push( trans([ v2[0], v1[1] ]) )
    nvects.push( trans(v2) )
    nvects.push( trans([ v1[0], v2[1] ]) )
    nvects.push( trans(v1) )
    device_multiline(nvects, closed)
    set_style() unless style == nil
  end

  def box2( v1, v2, style = nil, closed = false )

    nvects = []
    nvects.push( trans(v1) )
    nvects.push( trans([ v2[0], v1[1] ]) )
    nvects.push( trans(v2) )
    nvects.push( trans([ v1[0], v2[1] ]) )
    nvects.push( trans(v1) )

    tempstyle = @style.dup
    if style != nil then
      tempstyle.color = style.background
    else
      tempstyle.color = Color::White
    end

    set_style(tempstyle)
    device_multiline(nvects, closed)
    set_style(style) unless style == nil
    device_multiline(nvects, false)
#    print "return", @defaultstyle.color, "\n"
    set_style() 
  end

  def mkpoly(n, first, deltatheta, size)
    res = (0 .. n).collect{ |i| ( first + deltatheta * i ) * PI / 180.0 }
    res.collect{ | theta | [ size * cos(theta), size * sin(theta) ] }
  end
  
  def vadd( v1, v2 )
    v1[0] += v2[0]
    v1[1] += v2[1]
    v1
  end

  def sym_common(vects, closed, style)

    tempstyle = @style.dup

    if closed then
      tempstyle.color = style.color
      set_style( tempstyle )
      device_multiline( vects, closed )
      set_style()
#      set_style( @style ) 
    else
      tempstyle.color = Color::White
      set_style( tempstyle )
#      device_multiline( vects, true )
      tempstyle.color = style.color
      set_style ( tempstyle )
      device_multiline( vects, false )
      set_style()

#      set_style( @style ) 
    end
  end

  def sym_circle(v0, closed = nil, style  = @style, factor = 1.0)
    symsize = @defaultsymsize * factor
    vects = mkpoly( 18 , 0, 20, symsize * @xwidth).collect{ |v| vadd(trans(v0), v) }
    sym_common(vects, closed, style)
  end

  def sym_triangle(v0,  closed = nil, style = @style, factor = 1.0)
    symsize = @defaultsymsize * factor
    vects = mkpoly( 3 , 90 + @dtheta, 120, symsize * @xwidth).collect{ |v| vadd(trans(v0), v) }
    sym_common(vects, closed, style)
  end

  def sym_triangle_reverse(v0,  closed = nil, style = @style, factor = 1.0)
    symsize = @defaultsymsize * factor
    vects = mkpoly( 3 , 30 + @dtheta, 120, symsize * @xwidth).collect{ |v| vadd(trans(v0), v) }
    sym_common(vects, closed, style)
  end

  def sym_square(v0,  closed  = nil, style = @style, factor = 1.0)
    symsize = @defaultsymsize * factor
    vects = mkpoly( 4 , 45 + @dtheta, 90, symsize * @xwidth).collect{ |v| vadd(trans(v0), v) }
    sym_common(vects, closed, style)
  end

  def sym_diamond(v0,  closed = nil, style = @style, factor = 1.0)
    symsize = @defaultsymsize * factor
    vects = mkpoly( 4 , 0 + @dtheta, 90, symsize * @xwidth).collect{ |v| vadd(trans(v0), v) }
    sym_common(vects, closed, style)
  end

  def sym_common_line(vects, order, style)
    tempstyle = @style.dup

    tempstyle.color = style.color
    set_style(tempstyle)
    order.each { |o|
      device_line( vects[ o[0] ], vects[ o[1] ] )
    }
    set_style(@style)
  end

  def sym_cross(v0, closed = nil, style = @style, factor = 1.0)
    symsize = @defaultsymsize * factor
    vects = mkpoly( 4 , 45, 90, symsize * @xwidth).collect{ |v| vadd(trans(v0), v) }
    order = [[0, 2], [1, 3] ]
    sym_common_line(vects, order, style)
  end

  def sym_plus(v0, closed = nil, style = @style, factor = 1.0)
    symsize = @defaultsymsize * factor
    vects = mkpoly( 4 , 0, 90, symsize * @xwidth).collect{ |v| vadd(trans(v0), v) }
    order = [[0, 2], [1, 3] ]
    sym_common_line(vects, order, style)
  end

  def sym_star(v0, closed = nil, style = @style, factor = 1.0)
    symsize = @defaultsymsize * factor
    vects = mkpoly( 8 , 0, 45, symsize * @xwidth).collect{ |v| vadd(trans(v0), v) }
    order = [[0, 4], [1, 5], [2, 6], [3, 7] ]
    sym_common_line(vects, order, style)
  end

  def header
    @fp.puts("-- new graph --\n")
  end

  def closer
    @fp.puts("-- end --\n")
    @fp.close
  end

  def set_font(font=@defaultfont)
    @font = font
    @fp.printf("Font = %s\n", @font)
  end

  def set_style( style = @defaultstyle )
    @style = style
    @fp.printf("Color = (%f, %f, %f)\n", @style.color[0], @style.color[1], @style.color[2])
    @fp.printf("LineWidth = %f\n", @style.width)
    @fp.printf("LineStyle = %s\n", @style.linestyle.to_s)
  end

#  def set_color(color=@defaultcolor)
#    @color = color
#    @fp.printf("Color = %s\n", @color)
#  end

  def device_multiline( vects, closed ) 
    @fp.printf("Filled ") if closed
    n = vects.size
    for i in 0 .. n - 2 do 
      device_line(vects[i], vects[i+1])
    end
  end

  def device_line(v1, v2)
    @fp.printf("Line (%f, %f)-(%f, %f)\n", v1[0], v1[1], v2[0], v2[1])
  end

  def device_putchar(str, v, justification, rotation = 0)
    @fp.printf("String [%s] at %f %f with just= %s rot = %f \n", str, v[0], v[1], justification, rotation)
  end

  def trans(v)
    v
  end

  def closer
    @fp.print "showpange\n"
  end
  
end

class PSCanvas < Canvas
=begin
==Class PSCanvas
--- PSCanvas.new(filename='ogre.ps', options)
      *filename 
        name of the file where actions are recorded.
      *options
      :size => 'A4', :orientation => 'Landscape', :defaultstyle => style, :defaultfont => font
=end
  attr_accessor :style, :font, :xwidth, :ywidth
  attr_accessor :orientation

#  def initialize(filename='ogre.ps', defaultstyle=Std_style, defaultfont=Std_font, pos1=[72, 72], pos2=[72*6.5, 72*10], options = {} )
  def initialize(filename='ogre.ps', options = {} )

    defaultstyle=Std_style
    defaultfont=Std_font
    pos1=[72*2, 72*2]
    pos2=[72*7.5, 72*11]
    @yinch = 210.0 / 25.4 * 72.0
    @papersize = 'A4'
    @header_p = false
#    @fp=File.new(filename, mode="w")

    @orientation = 'Portrait'

#
#   option :orientation => 'Landscape', :size => 'A4' e.g. can be passed
#   style and font are also given by this Hash-style options.
#

    if options.kind_of?(Hash) then
      options.each{|key, value|
        case key.to_s
        when 'size'
          if Papers[value] != nil then
            pos1 = [144, 144]
            pos2 = [Papers[value][0] / 25.4 * 72.0 - 72, Papers[value][1] / 25.4 * 72.0 - 72]
            @papersize = value
            @yinch = Papers[value][0] / 25.4 * 72.0 
          end
        when 'orientation'
          @orientation = 'Landscape' if value.upcase == 'LANDSCAPE'
          @orientation = 'Portrait' if value.upcase == 'PORTRAIT'
        when 'defaultstyle'
          defaultstyle = value
        when 'defaultfont'
          defaultfont = value
        else
          raise "Option #{key} => #{value} is not supported\n"
        end
      }
    end
    if @orientation == 'Landscape' then
      pos2[0], pos2[1] = pos2[1], pos2[0]
    end
    
    @pos1_whole, @pos2_whole = pos1.collect{|i| i.to_f}, pos2.collect{|i| i.to_f}
#    setwhole()
    super(filename, defaultstyle, defaultfont)
#    set_style(@style)
#    set_font(@font)
  end

#
# set 
#
  def setwhole
    setposition(@pos1_whole, @pos2_whole)
  end

  def setpart( lb, tr ) #Left Bottom [0.0], and Top Right[1.1]

    pos1 = [ @pos1_whole[0] + lb[0] * ( @pos2_whole[0] - @pos1_whole[0] ),
             @pos1_whole[1] + lb[1] * ( @pos2_whole[1] - @pos1_whole[1] ) ]
    pos2 = [ @pos1_whole[0] + tr[0] * ( @pos2_whole[0] - @pos1_whole[0] ), 
             @pos1_whole[1] + tr[1] * ( @pos2_whole[1] - @pos1_whole[1] ) ]
    setposition(pos1, pos2)

  end

  def setposition(pos1, pos2)
#    print "#{pos1},   #{pos2}\n"

    @pos1, @pos2 = pos1, pos2
    @x0, @y0 = pos1[0], pos1[1]
    
    @xwidth = pos2[0] - pos1[0]
    @ywidth = pos2[1] - pos1[1]
  end

  def header

    if ! @header_p then  # header is only once for a page in postscript
      @fp.print <<EOFHEADER
%!PS-Adobe-1.0
%%Creator: ogre (programed by S. Ohdachi)
%%Title: ogre.ps [#{Dir.pwd}/#{$PROGRAM_NAME}] @ #{ENV['HOSTNAME']}#{ENV['COMPUTERNAME']}
%%BoundingBOX #{@pos1[0].to_i} #{@pos1[1].to_i} #{@pos2[0].to_i} #{@pos2[1].to_i}
%%Orientation: #{@orientation}
%%DocumentPaperSizes: #{@papersize}
%%Pages: 0
%%

/M {moveto} bind def
/L {lineto} bind def
/R {rmoveto} bind def
/V {rlineto} bind def
/Lshow { currentpoint stroke M
  0 0 R show } def
/Rshow { currentpoint stroke M
  dup stringwidth pop neg 0 R show } def
/Cshow { currentpoint stroke M
  dup stringwidth pop -2 div 0 R show } def

EOFHEADER
      if @orientation == 'Landscape' then
          @fp.print <<LANDSCAPE
90 rotate
0 #{-@yinch} translate
LANDSCAPE
      end
      @header_p = true
    end
  end

  def set_style(at = @defaultstyle)
    @fp.printf("%f %f %f setrgbcolor\n",  at.color[0].to_f / 255.0, at.color[1].to_f / 255.0, at.color[2].to_f / 255.0)
    @fp.printf("%f setlinewidth\n", at.width)
    if at.linestyle ==  [0] || at.linestyle == nil  then
      @fp.printf("[ ] 0 setdash\n")
    elsif
      @fp.printf("[ %s ] 0 setdash\n", at.linestyle.join(' ') )	 
    end
  end

#  def set_color(color=@defaultcolor)
#    @fp.printf("%f %f %f setrgbcolor\n",  color['red'], color['green'], color['blue'])
#  end

  def set_font(font=@defaultfont)
    @fp.printf("%s findfont %d scalefont setfont\n",font.name, font.size)
  end

  def sym_circle(v0, closed = nil, style  = @style, factor = 1.0)
    symsize = @defaultsymsize * factor

    tempstyle = @style.dup

    nv = trans( v0 )

    if closed then
      tempstyle.color = style.background
    else
      tempstyle.color = Color::White
    end

#    if closed then
      set_style(tempstyle)
      @fp.printf("%f %f %f 0 360 arc fill\n", nv[0], nv[1], symsize * @xwidth)
#    end
    
    tempstyle.color = style.color
    set_style(tempstyle)
    @fp.printf("%f %f %f 0 360 arc stroke\n", nv[0], nv[1], symsize * @xwidth)
    set_style(@style) 

  end

  def device_line(v1, v2)
    @fp.printf("%f %f moveto %f %f lineto stroke \n",  v1[0], v1[1], v2[0], v2[1])
  end

  def device_putchar( str, v , justification, rotation = 0)
#    @fp.printf("%f %f moveto (%s) show \n", v[0], v[1], str)
#    print "just="+justification+"\n"

    @fp.printf("%f %f M \n", v[0], v[1])

    @fp.printf("currentpoint gsave translate %f rotate \n", rotation) if rotation != 0
    case justification.upcase
    when 'L'
      @fp.printf("(%s) Lshow \n", str)
    when 'R'
      @fp.printf("(%s) Rshow \n", str)
    when 'C'
      @fp.printf("(%s) Cshow \n", str)
    end
    @fp.printf("grestore\n") if rotation != 0
  end

  def device_putchar2( str, v , justification, rotation = 0)
    @fp.printf("%f %f M \n", v[0], v[1])

    @fp.printf("currentpoint gsave translate %f rotate \n", rotation) if rotation != 0

#    @fp.printf("%f %f moveto (%s) show \n", v[0], v[1], str)
#    print "just="+justification+"\n"

#
#      enclose one character within {}
#

    str.gsub!( /(_|\^|!|\\)([^{])/) {|one|
      one[0,1] + '{' + one[-1, 1] + '}'
    }
#    print "str = ", str, "\n"
    strs = []
    last = 0

#
#      search for patterns _{} ^{} !{} \{}
#
    str.scan( /(_|\^|!|\\)(\{.*?\})/) {|head, body|
      if $` != nil && last != $`.size then
	strs.push([ 0, str[last .. ($`.size - 1) ] ])
      end
      last = str.size - $'.size

      case head
      when '_'
	strs.push([ 1, body[1 .. -2] ] )
      when '^'
	strs.push([ 2, body[1 .. -2] ] )
      when '!'
	strs.push([ 3, body[1 .. -2] ] )
      when '\\'
	strs.push([ 0, body[1 .. -2] ] )
      end
    }
    if last != str.size then
      strs.push( [0, str[last .. str.size - 1 ] ] )
    end

    len = 0
    strs.each { |p|
      if p[0] == 0 || p[1] == 3 then
	len += p[1].size
      end
      if p[0] == 1 || p[1] == 2 then
	len += p[1].size * 0.7
      end
    }
    dummy = "e" * len.to_i

    case justification.upcase
    when 'L'
#
    when 'R'
      @fp.printf("(%s) stringwidth pop neg 0 R\n", dummy)
    when 'C'
      @fp.printf("(%s) stringwidth pop -2 div 0 R\n", dummy)
    end
    smallfont = @font.dup
    smallfont.size = smallfont.size * 0.8
    symbolfont = @font.dup
    symbolfont.name = '/Symbol'

    strs.each{|p|
      case p[0]
	when 0 
	@fp.printf("(%s) show\n", p[1])

	when 1 
	set_font(smallfont)
	@fp.printf("0 -%d R (%s) show\n", smallfont.size * 0.3, p[1] )
#	@fp.printf("(%s) show\n", p[1])
	@fp.printf("0 %d R\n", smallfont.size * 0.3 )
	set_font(@font)

	when 2 
	set_font(smallfont)
	@fp.printf("0 %d R (%s) show\n", smallfont.size * 0.6, p[1] )
#	@fp.printf("(%s) show\n", p[1])
	@fp.printf("0 -%d R\n", smallfont.size * 0.6 )
	set_font(@font)
	
	when 3
	set_font(symbolfont)
	@fp.printf("(%s) show\n", p[1])
	set_font(@font)
      end
    }

    @fp.printf("grestore\n") if rotation != 0
  end


  def device_multiline( vects, closed ) 
    n = vects.size
    if closed then
      @fp.printf("%f %f moveto ",  vects[0][0], vects[0][1])
      for i in 1 .. n-1 do 
	@fp.printf("%f %f lineto \n",  vects[i][0], vects[i][1])
      end
      @fp.printf("fill \n")
    else
      @fp.printf("%f %f moveto ",  vects[0][0], vects[0][1])
      for i in 1 .. n-1 do 
	@fp.printf("%f %f lineto \n",  vects[i][0], vects[i][1])
      end
      @fp.printf("stroke \n")
    end
  end

  def trans(v)
    [ @x0 + @xwidth * v[0], @y0 + @ywidth * v[1] ]
  end

  def closer
    @fp.printf("showpage\n")
    @fp.close
  end

end

class Layout
  def initialize(x1, y1, x2, y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
  end
end


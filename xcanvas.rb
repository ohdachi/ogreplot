require 'xlib'

class XCanvas < Canvas
  attr_accessor :style, :font, :xwidth, :ywidth
  attr_accessor :fastp # if true style specfication works

  def initialize( defaultstyle =Std_style, defaultfont = Std_font, pos1 = [72, 72], pos2 = [72*10,72*10])

    xw, yw = 800, 1200

    @dis = Xlib::Display.new
    @win=@dis.root.new_window(xw, yw)
    @win.show
    @canvas = @win.new_gc

    @canvas.fg = @dis.alloc_color 'black'
    @canvas.bg = @dis.alloc_color 'white'
    @win.clear

    @canvaswidth, @canvasheight = xw, yw
    @canvas.fg = @dis.alloc_color 'white'
    @canvas.fill_rect(0,0, xw-1, yw-1)
    @canvas.fg = @dis.alloc_color 'black'

    @fastp = false # default is style works

    @pos1_whole, @pos2_whole = pos1, pos2
    @style = defaultstyle.dup
    @font = defaultfont.dup

    @defaultstyle = @style.dup
    @defaultfont = @font.dup
    @at0 = @defaultstyle

    set_style(@style)
    set_font(@font)
    @defaultsymsize = 0.015

    setposition(pos1, pos2)
    #    set_style(@style)
    #    set_font(@font)
    if block_given? then
      yield(self)
      closer
      after_hook
    end

  end

  def before_hook
  end

  def after_hook
    p @xfont
  end

  def setwhole
    setposition(@pos1_whole, @pos2_whole)
  end

  def setpart( lb, tr ) #[0.0], [1.1]
    pos1 = [ @pos1_whole[0] + lb[0] * ( @pos2_whole[0] - @pos1_whole[0] ),
             @pos1_whole[1] + lb[1] * ( @pos2_whole[1] - @pos1_whole[1] ) ]
    pos2 = [ @pos1_whole[0] + tr[0] * ( @pos2_whole[0] - @pos1_whole[0] ), 
             @pos1_whole[1] + tr[1] * ( @pos2_whole[1] - @pos1_whole[1] ) ]
    setposition(pos1, pos2)

  end

  def setposition(pos1, pos2)

    @pos1, @pos2 = pos1, pos2
    @x0, @y0 = pos1[0], pos1[1]
    @xwidth = pos2[0] - pos1[0]
    @ywidth = pos2[1] - pos1[1]

  end

  def header
  end

  def set_style(at = @defaultstyle)

    if ! @fastp
      @canvas.fg = @dis.alloc_color Xlib::Color.new(at.color[0].to_i, at.color[1].to_i, at.color[2].to_i)
      @canvas.bg = @dis.alloc_color Xlib::Color.new(at.background[0].to_i, at.background[1].to_i, at.background[2].to_i)
    end

  end

  def set_font(font=@defaultfont)
    @font_name = %w(
  -adobe-helvetica-medium-r-normal--14-*-*-*-c-*-iso8859-1
  -misc-fixed-medium-r-normal--14-*-*-*-c-*-jisx0208.1983-0
  )
    @xfont = @dis.new_font @font_name
    @point = Xlib::Point.new 8,64
#    gc.draw_str str,point,font
  end

  def sym_circle(v0, closed = nil, style  = @style, factor = 1.0)
    symsize = @defaultsymsize * factor
    tempstyle = @style.dup

    nv = trans( v0 )

    if closed then
      @canvas.fill_oval nv[0], nv[1],  symsize * @xwidth, symsize * @xwidth, 0, 360 * 64
    end

    set_style(tempstyle)
      @canvas.draw_oval nv[0], nv[1],  symsize * @xwidth, symsize * @xwidth, 0, 360 * 64

    set_style(@style) 
  end

  def device_line(v1, v2)
    @canvas.draw_line(v1[0], v1[1], v2[0], v2[1])
  end

  def device_putchar(str, v, justification, rotation = 0)
    case justification.upcase
    when 'L'
      option = 0
      xvec = [0.0, 1.0]
    when 'R'
      option = 2
      xvec = [-1.0, 0.0]
    when 'C'
      option = 1
      xvec = [-0.5, 0.5]
    else
      option = 0
      xvec = [0.0, 1.0]
    end
    yvec = [0.0, 1.0]
    w = 30
    h = 30
    v1 = [v[0] + w * xvec[0], v[1] + h * yvec[0]]
    v2 = [v[0] + w * xvec[1], v[1] + h * yvec[1]]
    @canvas.draw_str str, v1[0].to_i, v1[1].to_i, @xfont
  end

  def device_putchar2( str, v , justification, rotation = 0)
    device_putchar( str, v , justification, rotation = 0)
  end


  def device_multiline( vects, closed ) 
    n = vects.size
    narr = vects.flatten.collect{|x| x.to_i}
    if closed then
      @canvas.fill_poly(narr,Xlib::COORD_ORIG, Xlib::POLY_FREE)
    else
      @canvas.draw_lines(narr, Xlib::COORD_ORIG)
    end

  end

  def trans(v)
    [ @x0 + @xwidth * v[0], @canvasheight - (@y0 + @ywidth * v[1]) ]
  end

  def closer
    @dis.flush
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


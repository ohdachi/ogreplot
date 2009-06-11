require 'vr/vruby'
require 'vr/vrcontrol'
require 'vr/vrhandler'
require 'canvas.rb'

class VRCanvas < Canvas

  attr_accessor :style, :font, :xwidth, :ywidth, :vr, :canvas

  def initialize(vrcanvas, defaultstyle=Std_style, defaultfont=Std_font, pos1=[72, 72], pos2=[72*10, 72*10] )
#  def initialize(canvas, defaultstyle=Std_style, defaultfont=Std_font, pos1=[72, 72], pos2=[72*5, 72*5] )

     @vr = vrcanvas
     @canvas = vrcanvas.canvas

#    print 'inspet canvas'
#    p @canvas

    @canvaswidth=@canvas.width
    @canvasheight=@canvas.height
#    print "size of the canvas #{@canvaswidth}-#{@canvasheight}"
    
    #    @pos1, @pos2 = @canvas.size
    @pos1_whole, @pos2_whole = pos1, pos2

    @style = defaultstyle.dup
    @font = defaultfont.dup

    @defaultstyle = @style.dup
    @defaultfont = @font.dup

    set_style(@style)
    set_font(@font)
    @defaultsymsize = 0.01

    setposition(pos1, pos2)
#    set_style(@style)
#    set_font(@font)

    if block_given? then
      self.clear
      yield(self)
#      after_hook
      closer
    end

  end

#
# set 
#
  def clear
    at = @defaultstyle
    @canvas.setBrush(RGB(at.background[0].to_i, at.background[1].to_i, at.background[2].to_i), 0)
    @canvas.fillRect(0, 0, @canvas.width, @canvas.height)
  end

  def closer
  end
  def before_hook
#    @vr.clear
#    @vr.refresh
  end

  def after_hook
    @vr.refresh
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
    @canvas.setPen(RGB(at.color[0].to_i, at.color[1].to_i, at.color[2].to_i), at.width )
    @canvas.setBrush(RGB(at.background[0].to_i, at.background[1].to_i, at.background[2].to_i), 0)
  end

#  def set_color(color=@defaultcolor)
#    @fp.printf("%f %f %f setrgbcolor\n",  color['red'], color['green'], color['blue'])
#  end

  def set_font(font=@defaultfont)
# @canvas.setFont('Arial', 12)
# @vrfont = SWin::LWFactory::newfont('Arial', 12)
=begin
      rFactory = SWin::LWFactory.new SWin::Application.hInstance
      @vrfont = rFactory.newfont("Arial", 20)
      print 'font='
      p @vrfont
=end
      @vr.set_font('Arial', 24)
end

  def sym_circle(v0, closed = nil, style  = @style, factor = 1.0)
    symsize = @defaultsymsize * factor

    tempstyle = @style.dup

    nv = trans( v0 )
    if closed then
      tempstyle.background = style.background
    end

    set_style(tempstyle)
#    @fp.printf("%f %f %f 0 360 arc fill\n", nv[0], nv[1], symsize * @xwidth)

#    tempstyle.color = style.color
#    p symsize, nv[0] - symsize * @xwidth
#    p symsize, nv[0] + symsize * @xwidth
    @canvas.fillEllipse(nv[0] - symsize * @xwidth, nv[1] - symsize * @ywidth, nv[0] + symsize * @xwidth, nv[1] + symsize * @ywidth)
    set_style(@style) 

  end

  def device_line(v1, v2)
    @canvas.grMoveTo(v1[0], v1[1])
    @canvas.grLineTo(v2[0], v2[1])
  end

  def device_putchar(str, v, justification, rotation = 0)
#    @fp.printf("%f %f moveto (%s) show \n", v[0], v[1], str)
#    print "just="+justification+"\n"

=begin
Const DT_LEFT = &H0
Const DT_CENTER = &H1
Const DT_RIGHT = &H2
Const DT_WORDBREAK = &H10
Const DT_SINGLELINE = &H20
Const DT_TOP = &H0
Const DT_VCENTER = &H4
Const DT_BOTTOM = &H8
Const DT_NOCLIP = &H100
Const DT_CALCRECT = &H400
=end
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
    yvec = [-0.5, 0.5]
    #   p v1, v2, str
    w, h = @canvas.textExtent(str)
    v1 = [v[0] + w * xvec[0], v[1] + h * yvec[0]]
    v2 = [v[0] + w * xvec[1], v[1] + h * yvec[1]]
    @canvas.drawText(str, v1[0].to_i, v1[1].to_i, v2[0].to_i,  v2[1].to_i, str.size, option)
  end

  def device_putchar2( str, v , justification, rotation = 0)
    device_putchar( str, v , justification, rotation = 0)
  end


  def device_multiline( vects, closed ) 
    n = vects.size

    if closed then

      @canvas.grMoveTo(vects[0][0], vects[0][1])
      for i in 1 .. n-1 do 
	@canvas.grLineTo(vects[i][0], vects[i][1])
      end
    else
      @canvas.grMoveTo(vects[0][0], vects[0][1])
      for i in 1 .. n-1 do 
	@canvas.grLineTo(vects[i][0], vects[i][1])
      end
    end

  end

  def trans(v)
    [ @x0 + @xwidth * v[0], @canvasheight - (@y0 + @ywidth * v[1]) ]
  end

  def closer
    print "closer\n"
#    @canvas.refresh
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


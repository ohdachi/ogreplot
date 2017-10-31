class VTKCanvas < Canvas
=begin
==Class VTKCanvas
--- VTKCanvas.new(filename='ogre.vtk', options)
      *filename 
        name of the file where actions are recorded.
      *options

=end
  attr_accessor :style, :font, :xwidth, :ywidth
  attr_accessor :orientation

  attr_accessor :v1, :v2, :charsizefactor, :pos1, :pos2
#  def initialize(filename='ogre.ps', defaultstyle=Std_style, defaultfont=Std_font, pos1=[72, 72], pos2=[72*6.5, 72*10], options = {} )
  def initialize(filename='ogre.vtk', options = {} )

    defaultstyle=Std_style
    defaultfont=Std_font

    pos1=[0.0, 0.0]
    pos2=[10*7.5, 10*11.0]
    @points = [] # container for gnerationg vtk file
    @blocks = [] # container for vtk objects
    @npoints = 0 # pointer of the last points
    
    @v13d = [1.0, 0.0, 0.0] # vector in 3D space for xaxis
    @v23d = [0.0, 0.0, 1.0] # vector in 3D space for yaxis
    @origin3d = [0.0, 0.0, 0.0] # vector in 3D space for left-bottom

    @charsizefactor=1.0

    dir = File.expand_path(File.dirname(__FILE__))
    f = File.open(dir +'/font.dat')
    @cdb = Marshal.load(f)
    f.close
    
    if options.kind_of?(Hash) then
      options.each{|key, value|
        case key.to_s
        when 'v13d'
          @v13d = value
        when 'v23d'
          @v23d = value
        when 'origin3d'
          @origin3d = value
        when 'pos1'
          pos1 = value
        when 'pos2'
          pos2 = value
        when 'charsizefactor'
          @charsizefactor = value
        else
          raise "Option #{key} => #{value} is not supported\n"
        end
      }
    end
    @pos1_whole, @pos2_whole = pos1.collect{|i| i.to_f}, pos2.collect{|i| i.to_f}
    setposition(pos1, pos2)
#    defaultfont =  ['BTS32B', @xwidth*0.025*@charsizefactor]
    defaultfont =  Font.new('BTS32B', 0)
    super(filename, defaultstyle, defaultfont)
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
#    print @fp
    if ! @header_p then  # header is only once for a page in postscript
       @fp.print <<EOFHEADER
# vtk DataFile Version 2.0
ogre output
ASCII
DATASET UNSTRUCTURED_GRID
EOFHEADER
      @header_p = true
    end
  end

  def set_style(at = @defaultstyle)
    @style= at
  end

  def set_color(color=@defaultcolor)
#    @fp.printf("%f %f %f setrgbcolor\n",  color['red'], color['green'], color['blue'])
  end

  def set_font(font=@defaultfont)
#    @fp.printf("%s findfont %d scalefont setfont\n",font.name, font.size)
  end

  def set_font(font=@defaultfont)
    @font = font
#    @fp.printf("Font = %s\n", @font)
  end

  def set_style( style = @defaultstyle )
    @style = style
  end

  def set_color(color=@defaultcolor)
  end

  def device_multiline( vects, closed ) 
    #    @fp.printf("Filled ") if closed
    block = []
    n = vects.size
    for i in 0 .. n-1 do 
      @points.push(vects[i])
      block.push(@npoints)
      @npoints += 1
    end
    @blocks.push(block)
  end

  def trans_sf(x)
    ans = ['??', 0]

    ans = ['mx', x - 0x21] if x >= 0x21 && x <= 0x26
    ans = ['mx', x - 0x28+(0x26-0x21+1)] if x >= 0x28 && x <= 0x3F
    ans = ['dx', x - 0x40] if x >= 0x40 && x <= 0x5B
    ans = ['dx', x - 0x5E+(0x5B-0x40+1)] if x >= 0x5E && x <= 0x5F
    ans = ['nx', x - 0x60] if x >= 0x60 && x <= 0x7D
    ans = ['my', x - 0x7E] if x == 0x7E
    ans = ['my', x - 0xA1+1] if x >= 0xA1 && x <= 0xBF
    ans = ['dy', x - 0xC0] if x >= 0xC0 && x <= 0xDF
    ans = ['end', 0] if x == 0x20

    ans
  end

  def trans_c(x, y, xoff, yoff, tmat)
    #    [x*scale+xoff, y*scale+yoff]
    [ x * tmat[0][0] + y * tmat[0][1] + xoff, x * tmat[1][0] + y * tmat[1][1] + yoff]
  end
  
  def device_putchar(str, v, justification, rotation = 0)
    if str != nil then
      delta = 32
      mov0 = @xwidth*0.025*@charsizefactor

      mov = [mov0 * Math::cos(rotation / 180.0 * Math::PI ), mov0 * Math::sin(rotation / 180.0 * Math::PI )]

      scale = mov0/delta
      tmat = [ [ scale* Math::cos(rotation / 180.0 * Math::PI ), scale * Math::sin(-rotation / 180.0 * Math::PI )], [scale * Math::sin(rotation / 180.0 * Math::PI ), scale * Math::cos(rotation / 180.0 * Math::PI )] ]

      xoff = v[0]-Math::sin(rotation / 180.0 * Math::PI ) * 0.05 * @charsizefactor
      yoff = v[1]-Math::cos(rotation / 180.0 * Math::PI ) * 0.05 * @charsizefactor

      case justification.upcase
      when 'L'
      when 'R'
        xoff -= mov[0] * str.size * 1.0
        yoff -= mov[1] * str.size * 1.0
      when 'C'
        xoff -= mov[0] * str.size * 0.5
        yoff -= mov[1] * str.size * 0.5
      end
      scale = mov0/32
      i=0
      str.each_byte{|ii|

        chno =  ii.to_s(16).upcase

        l = @cdb[chno]
        pdraw = false
        x = x0 = 0.0
        y = y0 = 0.0
        block = []
        if l != nil then
          jj = 0
          l.each_byte{|c|
            cmd, data = trans_sf(c)
            if cmd == 'mx' then
              x0 = x = data
              @points.push( trans_c(x, y, xoff, yoff, tmat) )
              @npoints += 1
              if pdraw then
                @blocks.push(block)
                block = []
              end
              pdraw = false
            end
            if cmd == 'my' then
              y0 = y = data
              @points.push( trans_c(x, y, xoff, yoff, tmat) )
              @npoints += 1
              if pdraw then
                @blocks.push(block)
                block = []
              end
              pdraw = false
            end
            if cmd == 'nx' then
              x0 = x = data
            end
            if cmd == 'dx' then
              x0 = x
              x = data
              @points.push( trans_c(x, y, xoff, yoff, tmat) )
              if not pdraw then
                block.push(@npoints-1)
              end
              block.push(@npoints)
              @npoints += 1
              pdraw = true
            end
            if cmd == 'dy' then
              y0 = y
              y = data
              @points.push( trans_c(x, y, xoff, yoff, tmat) )
              if not pdraw then
                block.push(@npoints-1)
              end
              block.push(@npoints)
              @npoints += 1
              pdraw = true
            end
            if cmd == 'end' then
              if pdraw then
                @blocks.push(block)
                block = []
              end
            end
            jj += 1
          }
        end
        i += 1
        xoff += mov[0]
        yoff += mov[1]
      }
    end

  end

  def device_line(v1, v2)

    @points.push([v1[0], v1[1]])
    @points.push([v2[0], v2[1]])
    @blocks.push([@npoints, @npoints+1])
    @npoints += 2
  end

  def device_putchar2( str, v , justification, rotation = 0)
    device_putchar(str, v, justification, rotation)
  end

  def trans(v)
    [ @x0 + @xwidth * v[0], @y0  + @ywidth * v[1] ]
  end

  def closer
    @fp.print "POINTS #{@points.size} floats\n"
    #POINTS 66 floats
    @points.each{|x, y|
       tx = @v13d[0] * x + @v23d[0] * y + @origin3d[0]
       ty = @v13d[1] * x + @v23d[1] * y + @origin3d[1]
       tz = @v13d[2] * x + @v23d[2] * y + @origin3d[2]

      @fp.print "#{tx} #{ty} #{tz}\n"
    }
    @fp.print "CELLS #{@blocks.size} #{@blocks.flatten.size+@blocks.size}\n"
    @blocks.each{|block|
      @fp.print "#{block.size}"
      block.each{|point|
        @fp.print " #{point}"
      }
      @fp.print "\n"
    }
    @fp.print "CELL_TYPES #{@blocks.size}\n"
    @blocks.each{|block|
      @fp.print "4 "
    }
    @fp.print "\n"
#CELLS 2 68
#33 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 
#33 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 
#CELL_TYPES 2
#4 4
    @fp.close
#    print  @x0, ' ', @xwidth, ' ',  @y0, ' ',@ywidth, "\n"
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


class SVGCanvas < Canvas
=begin
==Class SVGCanvas
--- SVGCanvas.new(filename='ogre.svg', options)
      *filename 
        name of the file where actions are recorded.
      *options
      :size => 'A4', :orientation => 'Landscape', :defaultstyle => style, :defaultfont => font
=end
  attr_accessor :style, :font, :xwidth, :ywidth
  attr_accessor :orientation

#  def initialize(filename='ogre.ps', defaultstyle=Std_style, defaultfont=Std_font, pos1=[72, 72], pos2=[72*6.5, 72*10], options = {} )
  def initialize(filename='ogre.svg', options = {} )

    defaultstyle=Std_style
    defaultfont=Std_font
    pos1=[72, 72]
    pos2=[72*6.5*1, 72*10*1]
    @yinch = 210.0 / 25.4 * 72.0
    @papersize = 'A4'
    @header_p = false
#    @fp=File.new(filename, mode="w")

    @orientation = 'Portrait'
    @useid='ID01'
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
    @dtheta = 180
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
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="800pt" height="1200pt"
 xmlns="http://www.w3.org/2000/svg"
 xmlns:xlink="http://www.w3.org/1999/xlink">
EOFHEADER
      @header_p = true
    end
  end

  def set_style(at = @defaultstyle)
    @style= at
=begin
    @fp.printf("%f %f %f setrgbcolor\n",  at.color[0].to_f / 255.0, at.color[1].to_f / 255.0, at.color[2].to_f / 255.0)
    @fp.printf("%f setlinewidth\n", at.width)
    if at.linestyle ==  [0] || at.linestyle == nil  then
      @fp.printf("[ ] 0 setdash\n")
    elsif
      @fp.printf("[ %s ] 0 setdash\n", at.linestyle.join(' ') )	 
    end
=end
  end

#  def set_color(color=@defaultcolor)
#    @fp.printf("%f %f %f setrgbcolor\n",  color['red'], color['green'], color['blue'])
#  end

  def set_font(font=@defaultfont)
#    @fp.printf("%s findfont %d scalefont setfont\n",font.name, font.size)
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

    if closed then
      set_style(tempstyle)
       @fp.printf("<circle cx=\"%f\" cy=\"%f\" r=\"%f\" fill=\"rgb(%s)\" />\n", nv[0], nv[1], symsize * @xwidth, tempstyle.color.join(', ') )
    end
    
    tempstyle.color = style.color
    set_style(tempstyle)
    @fp.printf("<circle cx=\"%f\" cy=\"%f\" r=\"%f\" stroke=\"rgb(%s)\" fill=\"none\"/>\n", nv[0], nv[1], symsize * @xwidth, tempstyle.color.join(', ') )
    set_style(@style) 

  end

  def device_line(v1, v2)
#   @fp.printf("%f %f moveto %f %f lineto stroke \n",  v1[0], v1[1], v2[0], v2[1])
    if @style.linestyle == [0] then 
     @fp.printf("<line x1=\"%f\" y1=\"%f\" x2=\"%f\" y2=\"%f\" stroke-width=\"1\" stroke=\"rgb(%s)\" />\n" ,v1[0], v1[1],v2[0], v2[1], @style.color.join(',') )
   else
     @fp.printf("<line x1=\"%f\" y1=\"%f\" x2=\"%f\" y2=\"%f\" stroke-width=\"1\" stroke=\"rgb(%s)\" stroke-dasharray=\"%s\" />\n" ,v1[0], v1[1],v2[0], v2[1], @style.color.join(','), @style.linestyle.join(',') )
   end
  end

  def device_putchar( str, v , justification, rotation = 0)
    mul = 0.1 # em/eh :magic number for 14pnt font size 
    if rotation.to_f == 0 then 
      case justification.upcase
      when 'L'
        anchor = "start"
      when 'R'
        anchor = "end"
      when 'C'
        anchor = "middle"
      end

       @fp.printf("<g transform=\"translate(%f,%f)\" style=\"stroke:none; fill:black; font-family:Arial; font-size:%f; text-anchor:%s\">\n<text>%s</text>\n</g>", v[0], v[1] + @font.size * mul, @font.size, anchor, str)
    else
      print "#{str}, rotation = #{rotation}\n" if $debug
      case justification.upcase
      when 'L'
        anchor = "start"
      when 'R'
        anchor = "end"
      when 'C'
        anchor = "middle"
      end
       @fp.printf("<g transform=\"translate(%f,%f) rotate(%f)\" style=\"stroke:none; fill:black; font-family:Arial; font-size:%f; text-anchor:%s\">\n<text>%s</text>\n</g>", v[0], v[1] + @font.size * mul, -rotation, @font.size, anchor, str)
    end
  end
  def device_putchar2( str, v , justification, rotation = 0)
    device_putchar(str, v, justification, rotation)
=begin
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
=end
  end


  def device_multiline( vects, closed )
    if @style.linestyle != [0] then
      if closed then
        @fp.print("<symbol stroke-width=\"1\" id=\"#{@useid}\" stroke=\"rgb(#{@style.color.join(',')})\" fill=\"rgb(#{@style.color.join(',')})\" >\n")
        @fp.printf("<polygon points=\"")
      else
        fill = "none"
        @fp.print("<symbol stroke-width=\"1\" id=\"#{@useid}\" stroke=\"rgb(#{@style.color.join(',')})\" fill=\"none\" >\n")
        @fp.printf("<polyline points=\"")
      end
      n = vects.size
      vects.each{|v| @fp.printf("#{v.join(',')} ") }

      @fp.printf("\" />\n </symbol>\n")

      @fp.print("<use xlink:href=\"##{@useid}\" stroke-dasharray=\"#{@style.linestyle.join(',')}\" />\n")
      @useid.succ!
    else
      if closed then
        fill = "rgb(#{@style.color.join(',')})"
        @fp.printf("<polygon points=\"")
      else
        fill = "none"
        @fp.printf("<polyline points=\"")
      end
      vects.each{|v| @fp.printf("#{v.join(',')} ") }
      @fp.print("\" stroke-width=\"1\" stroke=\"rgb(#{@style.color.join(',')})\" fill=\"#{fill}\" />\n")
    end

  end

  def trans(v)
    [ @x0 + @xwidth * v[0], @y0  + @ywidth - @ywidth * v[1] ]
  end

  def closer
    @fp.printf("</svg>\n")
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


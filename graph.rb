=begin
= ogre: 
== Object oriented Graph plot program on Ruby environment
=== Programed by Satoshi Ohdachi ( Ohdachi@nifs.ac.jp )
===    ver 0.01 Dec. 2000
===    ver 0.1 Aug. 2007
===    ver 1.0 Jun. 2009 registered to Google Code
=end

=begin
= class Graph
== class method
--- Graph::new( array, column1, column2, options )
: options
:xrange => [0.0, 1.0], :yrange, :gtype => Ogre::Scatter, :symtype, :label(for legend)

== usage
: Simple plot from filename
g1 = Graph.new('filename', c1, c2 :gtype => Ogre::Scatter, :symtype => 4)
       * plot data[*][c1], data[*][c2] with symbol=4

: Plot a scatter graph of several data sharing the same x-axis
g2 = Graph.new(data, 0, [2, 3, 4], :gtype => Ogre::Line)
       * plot data[*][0], data[*][2]
       * plot data[*][0], data[*][3]
       * plot data[*][0], data[*][4]

: Plot a scatter graph with y-errorbar
g4 = Graph.new(data, 0, [1, 2], :gtype => Ogre::Scatter|Ogre::YError )
       * plot data[*][0], data[*][1] +- data[*][2]
       * error bar is ploted 

: Plot a graph both with x and y errobars.
g5 = Graph.new(data, [0, 1, 2], [3, 4], :gtype => Ogre::Scatter|Ogre::XError|Ogre::YError )
       * plot data[*][0] + data[*][1] - data[*][2], data[*][3] +- data[*][4]

: Plot with calculations using method 
p  g6 = Graph.new(data, 0, 1) { |d|
     [ d[3] * 2, d[4]^2 + 1]
  }
       * manuplation of values are represented as a iterator blocks.

== instance method
--- Graph#plot(dev)
Plot graphs on device ((|dev|)).


=end
module Ogre
include Math
require 'color.rb'
require 'defs.rb'
#include Ogre

require 'canvas.rb'

class Graph
  attr_accessor :plot, :axis, :axis1, :axis2
  attr_accessor :xaxis, :yaxis, :x2axis, :y2axis
  attr_accessor :x3axis, :y3axis, :x4axis, :y4axis
  attr_accessor :legend, :legend_show, :legend_pos
  attr_accessor :xrange, :yrange
  attr_accessor :gtype, :label
  attr_accessor :symtype, :symfactor, :symbol
  attr_accessor :legend
  attr_accessor :barwidth
  attr_accessor :xarr, :yarr # for contour plot
  attr_accessor :clines, :levels # for contour plot
  
  def initialize(data, c1 = 0, c2 = 0, options = {}, &proc)
#
#   Set up for axis (xaxis, yaxis, ..., y4axis)
#          standard setup is from Ogre::Std_axisstyle[]
#
    Ogre::Std_axisstyle.each{ |ax|
#      p ax.instancename, "\n"
      self.send(ax.instancename, Axis.new(ax) )
    }
    @axis=[@xaxis, @yaxis, @x2axis, @y2axis, @x3axis, @y3axis, @x4axis, @y4axis]
    #    p @axis
#
#   Set up for symbols
#          standard setup is from Ogre::Std_plotstyle[]
#
    @symarray=[]
    Ogre::Std_plotstyle.each{ |ps| 
      @symarray.push( PlotSymbol.new( ps ) )
    }
#
#   set up for Bar
#
    @nbar=Ogre::Bar_Style.size
#   
#   defalut no legend
#
    @legend_show = false
    @legend_pos = 0 # default = left upper (see defs.rb)

    @symtype0 = 0 # default value
    @bartype0 = 0 
#
#   Create a new plot
#
    @plots = []
    add(data, c1, c2, options, &proc)
    @legend = Legend.new( Ogre::Std_legendstyle[@legend_pos % 4]) # legend to hold
    @texts = []
    @texts_conv = []
    @lines = []
    @lines_conv = []
    @extra_symbols = []
    @extra_bars = []
    @images = []
  end

  def add(data, c1 = 0, c2 = 0, options = {}, &proc)
    #
    #   syntax sugar (if data is a filename? )
    #
    if data.kind_of?(String) then
      require 'readfile.rb'
      data = Readfile.new(data).read
    end
    #
    #   if called with block, calculate the matrix with the block
    #
    if block_given? then
      print yield([ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 ]), "\n" if $debug
      print "block_given\n" if $debug
      ndata = data.collect{|d| yield(d) }
      data = ndata.reject{|d| d == [] || d == nil}

      print "block given: ndata size #{data.size}\n" if $debug
      p data if $debug
    end

#
#   default values (should be defined in defs.rb)
#

#   plot on xaxis, yaxis 
    @axis1 = 0
    @axis2 = 1
#
#   scatter plot is default
#
    @gtype = Ogre::Scatter
    @symtype = nil
    @symfactor = nil

    @xrange = @yrange = nil
    @label = nil
    @barwidth = nil
#
#   if options are given in Hash style, set it.
#

      if options.kind_of?(Hash) then
        options.each{|key, value|
          begin
            self.send(key.to_s + '=', value)
          rescue
            printf("'%s' is not the chractreisitc of class Graph. It is ignored \n", key)
#           raise, "#{key} is not a characteristiec of the class Graph. ignored")
          end
        }
      end
#    @label = [ @axis[@axis2].title ] if @label == nil
    @label = [ @label ] unless @label.kind_of?(Array)


    if @symbol == nil then
# if the symbol is not specified, use default symbols
      @symbols = @symarray
    else
# if the symbol is specified
      if @symbol.kind_of?(Array) then
        @symbols = @symbol.collect{|sym| PlotSymbol.new(sym)}
      else
        @symbols = [PlotSymbol.new(@symbol)]
      end
    end
    @nsymbol = @symbols.size

#
#   if support for multiculumn
#
    @symtype =  @symtype0 if @symtype == nil
    unless @symtype.kind_of?(Array) then
      @symtype = [ @symtype ]
      @symfactor = 1.0 if @symfactor == nil
#
#     if only one symbol is specified and y-data are multi,
#     set the symbol array-style in incremental order.
#
      if c2.kind_of?(Array) then
        if c2.size > 1 then 
          (1 ... c2.size ).each{ |c|
            @symtype.push( ( @symtype[-1]  + 1 ) % @nsymbol )
          }
        end
      end
    end


#
#   make error data 
#
#   xerror
#
    xedata = yedata = nil
    if  gtype & Ogre::XError != 0 then
      if c1.kind_of?(Array) then
        if c1.size == 2 then
          dc, ec = c1[0], c1[1]
          xedata = data.collect{|d| [ d[dc] - d[ec], d[dc] + d[ec] ] }
        elsif c1.size == 3 then
          ec1, ec2 = c1[1], c1[2]
          xedata = data.collect{|d| [ d[ec1], d[ec2] ] }
        end
	c1 = c1[0]
      else
	raise 'no x-error column is specified'
      end
    end
#
#   yerror
#
    if  gtype & Ogre::YError !=0 then
      if c2.kind_of?(Array) then
        if c2.size == 2 then
          dc, ec = c2[0], c2[1]
          yedata = data.collect{|d| [ d[dc] - d[ec], d[dc] + d[ec] ] }
        elsif c2.size == 3 then
          ec1, ec2 = c2[1], c2[2]
          yedata = data.collect{|d| [ d[ec1], d[ec2] ] }
        end
	c2 = c2[0]
      else 
	raise 'no y-error column is specified';
      end
    end
#
#   bar plot
#
    if  gtype & Ogre::Bar !=0  then
      
      if c1.kind_of?(Array) then
        if c1.size == 2 then
          ec1, ec2 = c1[0], c1[1]
          xedata = data.collect{|d|  [ d[ec1], d[ec2] ] }
          c1 = [ c1[0] ]
        else
          raise 'please specify 2 columns for Bar plot'
        end
      else
        if @barwidth == nil then
          txarr = data.collect{|d| d[c1]}.sort
          @barwidth = (0 ... txarr.size - 1).collect{ |i| txarr[i + 1] - txarr[i] }.select{|x| x > 0 }.min
        end
        dc = c1
        xedata = data.collect{|d| [ d[dc] + @barwidth * 0.5, d[dc] - @barwidth * 0.5] }
      end

      if c2.kind_of?(Array) then # stacked bar graph
        yedata = data.collect{|d|
          (0 ... c2.size - 1).collect{|i|
            [ d[ c2[i] ], d[ c2[i + 1] ], 0.0 ]
          }
        }
	cye = (0 ... c2.size).collect{|i| i }
        c2 = c2[1 .. -1] # if up and bottom values are specifyed, number of data is number of C2 -1
      else
	yedata = data.collect{|d| [[0.0, d[c2] ]]} 
        cye = 0
      end
      if @xrange == nil then
        temp = xedata.flatten
        vmin, vmax = temp.min, temp.max
        print "xrange = #{vmin}, #{vmax}\n" if $debug
        @xrange = [vmin, vmax]
      end
      if @yrange == nil then
        temp = yedata.flatten
        vmin, vmax = temp.min, temp.max
        print "yrange = #{vmin}, #{vmax}\n" if $debug
        @yrange = [vmin, vmax]
      end
    end
#
#   contour plot
#

    if @gtype & Ogre::Contour != 0 then
      n1 = data[0].size
      n2 = data.size
      @xarr = (0 .. n1-1).collect{|i| i.to_f} if @xarr == nil
      @yarr = (0 .. n2-1).collect{|i| i.to_f} if @yarr == nil
    end
#
#   if multi column is specified, we call Plot.new for each combination
#
    c1 = [c1] unless c1.kind_of?(Array) 
    c2 = [c2] unless c2.kind_of?(Array)
    cye = [0] if cye == nil
    cye = [cye] unless cye.kind_of?(Array)

    nmax = [c1.size, c2.size].max
    print 'c1 = ', c1, 'c2 = ', c2, "\n" if$debug

    (0 ... nmax).each{ |i|
      newx = @axis[@axis1].withdata == nil
      newy = @axis[@axis2].withdata == nil

      if $debug then
        print "@label=",  @label[i % @label.size], "\n"
        print "c1=#{c1}\n"
        print "c2=#{c2}\n"
        print "cye = #{ cye}\n"
        print "yedata = "
#        p yedata
        print "\n"
        print "symtype = #{@symtype}\n"
      end
      
      @plots.push(
        Plot.new(data, xedata, yedata, c1[i % c1.size], c2[i % c2.size], cye[ i % cye.size],
          @axis[@axis1], @axis[@axis2], gtype,
          @symbols[@symtype[ i % @symtype.size ]  % @nsymbol],
          @symfactor,
          @symtype[ i  % @symtype.size] % @nbar,
          @label[ i % @label.size],
          @xarr, @yarr, @levels) )

      @axis[@axis1].range = @xrange if @axis[@axis1].range == nil
      @axis[@axis2].range = @yrange if @axis[@axis2].range == nil
    }

  end

  def add_text(str, v, just='C', offset = [0.0, 0.0], rot = 0, font = nil)
    @texts.push( Text.new(str, v, just, offset, rot, font) )
  end

  def add_text_conv(str, v, just='C', offset = [0.0, 0.0], rot = 0, font = nil)
    @texts_conv.push( Text.new(str, v, just, offset, rot, font) )
  end

  def add_line(v1, v2, arrow = [nil, nil], style = nil)
    @lines.push( Line.new(v1, v2, arrow, style) )
  end

  def add_line_conv(v1, v2, arrow = [nil, nil], style = nil)
    @lines_conv.push( Line.new(v1, v2, arrow, style) )
  end

  def add_symbol(v, symbol = @symarray[@symtype0], factor = 1.0)
    @extra_symbols.push([v, symbol, factor])
  end

  def add_bar(v1, v2,  style = Ogre::Bar_Style[@bartype0], factor = 1.0)
    @extra_bars.push([v1, v2, style, factor])
  end

  def add_image(mat, v1, v2, imgmin = 0.0, imgmax = 255.0, color_pallet = 0)
    @images.push([mat, v1, v2, imgmin, imgmax, color_pallet])
  end

  def plot(dev)
#
#     setup fontsize <-> canvas size 
#
    dev.before_hook

    ew = dev.font.size.to_f / dev.xwidth.to_f * 0.6
    eh = dev.font.size.to_f / dev.ywidth.to_f * 0.6

    Text::ewehset(ew, eh)
#
#   draw plots
#

# background of the graph
#    dev.box2([0.0, 0.0], [1.0, 1.0], Ogre::Bg, true)


    # calculate width of the vmax and vmin

    @axis.each{|ax| ax.setwidth}
    
    @plots.each{ |p|
      p.plot(dev,@legend)
    }

   @axis.each_with_index{ |a, i|
      #    mirror   tick_specified
#     y           y               copy range, tick, mtick
#                 n               copy range, keep tick, mtick

      if a.mirror != nil then
	a.range  = [ axis[a.mirror].min, @axis[a.mirror].max ]
	if a.tick_specify != true then
	  a.ticks = @axis[a.mirror].ticks
	  a.mticks = @axis[a.mirror].mticks
	end
      end
    }
    
#
#   draw extra texts
#
    @texts.each{|t| t.plot(dev) }
    @texts_conv.each{|t|
      t.v = [@xaxis.frac(t.v[0]), @yaxis.frac(t.v[1])]
      t.plot(dev)
    }
#
#   draw extra lines
#
    @lines.each{|l| l.plot(dev) }
    @lines_conv.each{|t|
      t.v1 = [@xaxis.frac(t.v1[0]), @yaxis.frac(t.v1[1])]
      t.v2 = [@xaxis.frac(t.v2[0]), @yaxis.frac(t.v2[1])]
      t.plot(dev)
    }
#
#   draw extra symbols
#
    @extra_symbols.each{|r, symbol, factor|
      v = [@xaxis.frac( r[0] ), @yaxis.frac( r[1] ) ]
#      p symbol.pstyle.style.color
       symbol.plot(dev, v, factor ) if ! @clip || bound( v )
    }
    @extra_bars.each{|v1, v2, style, factor|
       x1, y1 = @xaxis.frac( v1[0] ), @yaxis.frac( v1[1] )
       x2, y2 = @xaxis.frac( v2[0] ), @yaxis.frac( v2[1] )
#      p symbol.pstyle.style.color
       dev.box2( [x1, y1], [x2, y2], style.style, style.closed)
    }

    @images.each{|mat, v1, v2, imgmin, imgmax, color_pallet|
      
       if mat.kind_of?(Array) then
         n2 = mat.size
         n1 = mat[0].size
         dx = (v2[0]-v1[0]) / n1
         dy = (v2[1]-v1[1]) / n2
         print "dx = #{dx}, dy = #{dy}"
         p v1
         p v2
         print  "n1 = #{n1}, n2 = #{n2}\n"
         (0 ... n2).each{|j|
           (0 ... n1).each{|i|
             x1, y1 = @xaxis.frac( v1[0] + dx * i ), @yaxis.frac( v1[1] + dy * j)
             x2, y2 = @xaxis.frac( v1[0] + dx * (i + 1) ), @yaxis.frac( v1[1] + dy * (j + 1))

             var = mat[j][i]
             use = (var.to_f - imgmin) / (imgmax - imgmin) * 255
             style = Ogre::Color_pallet[color_pallet][use.to_i]
#             p style
             dev.box2( [x1, y1], [x2, y2], style, true)
           }
         }
       end
       
    }

    
#
#   draw axis
#
    @axis.each{|a|
      a.plot(dev)
    }
#
#   draw lengend
#
    if @legend_show then
      @legend.plot(dev)
    end
#   close device
#
    dev.after_hook
  end

=begin  
  def method_missing(methid, args)
    fprintf(stderr, "%s is not the chractreisitc of class Graph\n", methid.id2name)
  end
=end

  class Plot
    attr_accessor :data, :c1, :c2, :clip, :xarr, :yarr
    @@bs = nil
    def initialize(data, xedata, yedata, c1, c2, cye, xaxis, yaxis, gtype, symbol = nil, factor = 1.0, nbar = nil, label = '', xarr = nil, yarr = nil, levels = nil)

      @data = data
      @xedata , @yedata = xedata, yedata
      @c1, @c2, @cye= c1, c2, cye

      @xaxis, @yaxis= xaxis, yaxis
      @xaxis.withdata, @yaxis.withdata = true, true
      @xaxis.mirror, @yaxis.mirror = nil, nil

      @xaxis.ticklabel_show ,@yaxis.ticklabel_show = true, true

      @gtype = gtype
      @symbol = symbol
      @factor = factor
      @nbar = nbar
      
      @errsize = 0.01
      @clip = true
      @label = label
      @xarr = xarr
      @yarr = yarr
      @levels = levels
      @clines = {} # for contour
    end

#    @ptri = proc { |v0, color| sym_triangele(v0, color) }

#
#   vecter is in the plotting area?
#
    def bound(v)
      return ( v[0] >= 0.0 && v[0] <= 1.0 &&
               v[1] >= 0.0 && v[1] <= 1.0 )
    end
#
#   calculate intersection of line(v1 + t X (v2-v1) ) with boundary
#   nc : how many intersections beween line and boundaries
#
    def cross(v1, v2)
      dx, dy = v2[0] - v1[0], v2[1] - v1[1]
      cr = []                       # array containing intersections

      if dx == 0 and dy ==0 then
	nc = 0
      elsif dx == 0 then
	t = ( 0.0 - v1[1] ) / dy   # y = 0
	x , y = v1[0] + t * dx, v1[1] + t * dy
        cr.push( [x, y] ) if  x >= 0 && x <= 1 && t >= 0 && t <= 1
	t = ( 1.0 - v1[1] ) / dy   # y = 1
	x, y = v1[0] + t * dx, v1[1] + t * dy
	cr.push( [x, y] ) if x >= 0 && x <= 1 && t >= 0 && t <= 1
      elsif dy == 0 then
	t = ( 0.0 - v1[0] ) / dx   # x = 0
	x, y = v1[0] + t * dx, v1[1] + t * dy
	cr.push( [x, y] ) if y >= 0 && y <= 1 && t >= 0 && t <= 1
	t = ( 1.0 - v1[0] ) / dx   # x = 1
	x, y = v1[0] + t * dx, v1[1] + t * dy
        cr.push( [x, y] ) if y >= 0 && y <= 1 && t >= 0 && t <= 1
      else
	t = ( 0.0 - v1[1] ) / dy   # y = 0
	x , y = v1[0] + t * dx, v1[1] + t * dy
        cr.push( [x, y] ) if x >= 0 && x <= 1 && t >= 0 && t <= 1
	t =  ( 1.0 - v1[1] )  / dy   # y = 1
	x, y = v1[0] + t * dx, v1[1] + t * dy
	cr.push( [x, y] ) if x >= 0 && x <= 1 && t >= 0 && t <= 1
	t = ( 0.0 - v1[0] ) / dx   # x = 0
	x, y = v1[0] + t * dx, v1[1] + t * dy
	cr.push( [x, y] ) if y >= 0 && y <= 1 && t >= 0 && t <= 1
	t = ( 1.0 - v1[0] ) / dx   # x = 1
	x, y = v1[0] + t * dx, v1[1] + t * dy 
        cr.push( [x, y] ) if y >= 0 && y <= 1  && t >= 0 && t <= 1
      end
      return cr
    end

#
#   check the relative postiton of line(v1-v2) with box( [0,0]-[1,1] )
#   return 0-4 0: both in, 1 v1 in, 2 v2 in, 3 part line in, 4 both out
#

    def intersect( v1, v2 )
      b1,  b2 = bound( v1 ), bound( v2 )
      cr = []
      if b1 && b2 then
	res = 0
      elsif b1 then
	cr = cross( v1, v2 )
	res =1
      elsif b2 then 
	cr = cross( v1, v2 )
	res =2
      else
	cr = cross( v1, v2 )
	if cr.size == 2 then
	  res = 3
	else
	  res = 4
	end
      end
      return res, cr
    end

    def searchminmax(data, c)
      p data[0] if $debug

      if data.class != Array || data[0].class != Array
        raise 'Data should be 2D array like data[0][1]'
      end
      min = max = data[0][c].to_f
      data.each{ |d|
        if d[c] != nil then 
          min = d[c] if d[c] < min
          max = d[c] if d[c] > max
        end
      }
      if min == max then
        min = min - 0.5
        max = max + 0.5
      end
      return [min, max]
    end

    def drawline_with_clip(lines, dev)
      templine = []
      templine.push( lines[0] ) if bound( lines[0] )
      (0 ... lines.size - 1).each {|i|
        res, cr = intersect( lines[i], lines[i+1] )
        if res == 0 then   # if both point are inside
          templine.push( lines[i+1] )
        elsif res == 1 then  # only first point is inside
          templine.push( cr[0] )
          dev.multiline( templine, @symbol.pstyle.style )
          templine = []
        elsif res == 2 then  # second point is inside
          templine.push( cr[0] )
          templine.push( lines[i+1] )
        elsif res == 3 then  # only frangment is inside
          templine.push( cr[0] )
          templine.push( cr[1] )
          dev.multiline( templine, @symbol.pstyle.style )
          templine = []
        end
      }
      
      dev.multiline( templine, @symbol.pstyle.style ) if templine.size != 0
    end
    
    class Extendedlines
      attr_accessor :lines
      def initialize(x1, y1, x2, y2)
        @x1, @y1 = x1, y1
        @x2, @y2 = x2, y2
        @lines = [ [x1, y1], [x2, y2] ]
      end
      def add(x3, y3, x4, y4)
        pextend = true
        if @x1 == x3 && @y1 == y3 then
          @lines.unshift([x4, y4])
          @x1, @y1 = x4, y4
        elsif @x1 == x4 && @y1 == y4
          @lines.unshift([x3, y3])
          @x1, @y1 = x3, y3
        elsif @x2 == x3 && @y2 == y3 then
          @lines.push([x4, y4])
          @x2, @y2 = x4, y4
        elsif @x2 == x4 && @y2 == y4
          @lines.push([x3, y3])
          @x2, @y2 = x3, y3
        else
          pextend = false
        end
        pextend
      end
    end

    def contour
      n1 = @data[0].size
      n2 = @data.size
      (0 .. n1-2).each{|i|
        (0 .. n2-2).each{|j|
          x1, x2 = @xarr[i], @xarr[i+1]
          y1, y2 = @yarr[j], @yarr[j+1]
          triangle([ x1, y1, @data[j][i].to_f ], [x2, y1, @data[j][i+1].to_f ],[x2, y2, @data[j+1][i+1].to_f ])
          triangle([ x1, y1, @data[j][i].to_f ], [x1, y2, @data[j+1][i].to_f ],[x2, y2, @data[j+1][i+1].to_f ])
        }
      }
    end
    def triangle(p1, p2, p3)
      le = {}
      lines = [ [p1,p2], [p2,p3], [p3,p1] ]
      lines.each{ |t1, t2|
        x1, y1, v1 = t1
        x2, y2, v2 = t2
        
#      print "#{x1},  #{y1},  #{v1},  #{x2},  #{y2},  #{v2}\n"
        if v1 == v2 then
          @levels.each{|level|
            if level == v1 then
              addclines(v1, x1, y1, x2, y2)
            end
          }
        else
          @levels.each{|level|
            f1 = (v1 - level)
            f2 = (level - v2) 
            
            if f1 * f2 >= 0.0  then
              f1 /= (v1-v2)
              f2 /= (v1-v2)
              if le[level] == nil then
                le[level] = [ [x1 * f2 + x2 * f1, y1 * f2 + y2 * f1 ] ]
              else
                le[level].push([x1 * f2 + x2 * f1, y1 * f2 + y2 * f1 ])
              end
            end
          }
        end
      }
#      p p1, p2, p3, le
      le.each{|v, arr|
        if arr.size == 2 then
          addclines( v, arr[0][0], arr[0][1], arr[1][0], arr[1][1] )
        elsif arr.size == 3 then
          arr.uniq!
          addclines( v, arr[0][0], arr[0][1], arr[1][0], arr[1][1] ) 
#        else
#          print "!err!\n"
#          p p1, p2, p3, v, arr
#          print "!err!\n"
        end
      }
    end

    def addclines(v, x1, y1, x2, y2)
      if @clines[v] == nil then
        @clines[v] = [Extendedlines.new(x1, y1, x2, y2)]
      else
        pextended = false
        @clines[v].each{|el|
          if el.add(x1, y1, x2, y2) == true
            pextended = true
            break
          end
        }
        if pextended == false
          @clines[v].push(Extendedlines.new(x1, y1, x2, y2))
        end
      end
    end

    def plot(dev, legend)

#    miror  withdata range_spesified tick_specified 
#     nil       y           y               y        go  
#               y           y               n        use determticks
#               y           n               y        set range from data
#               y           n               n        use detertic
#
#      print "min,max = ", @xaxis.max, @xaxis.min, "\n"
      
#      @xaxis.range = searchminmax(@data, @c1) if ( @xaxis.min == nil || @xaxis.max == nil )
#      @yaxis.range = searchminmax(@data, @c2) if ( @yaxis.min == nil || @yaxis.max == nil )

#      print "xrange = #{@xaxis.range[0]},#{@xaxis.range[1]}\n" if $debug
#      print "yrange = #{@yaxis.range[0]},#{@yaxis.range[1]}\n" if $debug
      print "xrange = #{@xaxis.min},#{@xaxis.max}\n" if $debug
      print "yrange = #{@yaxis.min},#{@yaxis.max}\n" if $debug

      if @gtype & Ogre::Contour == 0 then
        xmin, xmax = searchminmax(@data, @c1)
        ymin, ymax = searchminmax(@data, @c2)
      else
        xmin, xmax = @xarr.min, @xarr.max
        ymin, ymax = @yarr.min, @yarr.max
      end

      if xmin == xmax && ! @xaxis.range_specify then
        @xaxis.range= [@xaxis.range[0] - 1, @xaxis.range[0] + 1]
      end

      if ymin == ymax && ! @yaxis.range_specify then
        @yaxis.range= [@yaxis.range[0] - 1, @yaxis.range[0] + 1]
      end

      if @xaxis.range_specify then
        @xaxis.determticks(1.0, 10, @xaxis.min, @xaxis.max) 
      else
        @xaxis.determticks(1.0, 10, xmin, xmax) 
      end

      if @yaxis.range_specify then
        @yaxis.determticks(1.0, 10, @yaxis.min, @yaxis.max) 
      else
        @yaxis.determticks(1.0, 10, ymin, ymax) 
      end
#
#
#
      legend_proc_arr = []
#
#     plot x-errorbars
#
      if @gtype & Ogre::Dummy != 0 then
	return
      end

      if @gtype & Ogre::XError != 0 then
	ndata = @data.size
        (0 ... ndata).each { |i|
	   dx, dy = @data[i][@c1], @data[i][@c2]
	   ex1, ex2 = @xedata[i][0], @xedata[i][1]
	   xerror_plot(dev, dx, dy, ex1, ex2)
        }
      end
#
#     plot x-errorbars
#
      if @gtype & Ogre::YError != 0 then
	ndata = @data.size
	(0 ... ndata).each { |i|
	  dx, dy = data[i][@c1], data[i][@c2]
	  ey1, ey2 = @yedata[i][0], @yedata[i][1]
	  yerror_plot(dev, dx, dy, ey1, ey2)
	}
      end
#
#     bar plot
#

      if @gtype & Ogre::Bar != 0 then
        ndata = @data.size
        (0 ... ndata ).each { |i|
          x1, x2 = @xedata[i][0], @xedata[i][1]
	  y1, y2 = @yedata[i][@cye][0], @yedata[i][@cye][1]
          unless x1 == x2 || y1 == y2
            style = Ogre::Bar_Style[@nbar]
            bar_plot(dev, @xaxis.frac(x1), @yaxis.frac(y1), 
		   @xaxis.frac(x2), @yaxis.frac(y2), style)
          end
        }
	p = Proc.new{ |dev, x, y, dx, dy|
	  bar_plot(dev, x - dx / 5.0, y - dx / 5.0, x + dx / 5.0, y + dx / 5.0, Ogre::Bar_Style[@nbar] ) 
	}
	legend_proc_arr.push(p) if @label != '' && @label != nil
#	legend.add( p, @label ) if @label != '' && @label != nil
      end
#
#     plot lines
#

      if @gtype & Ogre::Line != 0 then
	lines = data.collect{ |d|
	  [@xaxis.frac( d[@c1]), @yaxis.frac(d[@c2] )]
	}
	unless @clip then 
	  dev.multiline( lines, @symbol.pstyle.style  )
	end
#
#       clipping of lines
#
        drawline_with_clip(lines, dev)
	p = Proc.new{ |dev, x, y, dx, dy|
          dev.line([x - dx / 3.0, y], [x + dx / 3.0, y], @symbol.pstyle.style)
	}
	legend_proc_arr.push( p ) if @label != '' && @label != nil
#        legend.add( p, @label) if @label != '' && @label != nil
	
      end

      if @gtype & Ogre::Scatter != 0 then 
	data.each{ |d|
	  v = [@xaxis.frac( d[@c1] ), @yaxis.frac( d[@c2] ) ]
	  @symbol.plot(dev, v, @factor ) if ! @clip || bound( v )
	}
	p = Proc.new{ |dev, x, y, dx, dy| @symbol.plot(dev, [x, y], @factor ) }
	legend_proc_arr.push( p ) if @label != '' && @label != nil
#	legend.add( p, @label) if @label != '' && @label != nil
      end

      if @gtype & Ogre::Contour != 0 then
        contour()
        ip = 0
        @clines.each{|v, cl|
          #      p v
          cl.each{|e|
            #p e.lines
            lines = e.lines.collect{|data|
              [@xaxis.frac( data[0]), @yaxis.frac(data[1])]
            }
            unless @clip then 
              dev.multiline( lines, @symbol.pstyle.style  )
            else
#             @symbol = PlotSymbol.new(Ogre::Std_plotstyle[ip])
              drawline_with_clip(lines, dev)
            end
          }
#          ip = (ip + 1) % 8
        }
      end
      legend.add( legend_proc_arr, @label ) if legend_proc_arr.size != 0 
    end
    def xerror_plot(dev, dx, dy, ex1, ex2)
      d2 = @xaxis.frac( dy )
      if d2 >= 0.0 && d2 <=1.0 then
        dev.line( [ @xaxis.frac( ex1 ), @yaxis.frac( dy ) ], 
          [ @xaxis.frac( ex2 ), @yaxis.frac( dy ) ] )
        dev.line( [ @xaxis.frac( ex1 ), @yaxis.frac( dy ) + @errsize ], 
          [ @xaxis.frac( ex1 ), @yaxis.frac( dy ) - @errsize ] )
        dev.line( [ @xaxis.frac( ex2 ), @yaxis.frac( dy ) + @errsize ], 
          [ @xaxis.frac( ex2 ), @yaxis.frac( dy ) - @errsize ] )
        end
    end
    def yerror_plot(dev, dx, dy, ey1, ey2)
      d1 = @xaxis.frac( dx )
      if d1 >= 0.0 && d1 <= 1.0 then
        dev.line( [ @xaxis.frac( dx ), @yaxis.frac( ey1 ) ], 
          [ @xaxis.frac( dx ), @yaxis.frac( ey2 ) ] )
        dev.line( [ @xaxis.frac( dx ) + @errsize, @yaxis.frac( ey1 ) ], 
          [ @xaxis.frac( dx ) - @errsize, @yaxis.frac( ey1 ) ] )
        dev.line( [ @xaxis.frac( dx ) + @errsize, @yaxis.frac( ey2 ) ], 
          [ @xaxis.frac( dx ) - @errsize, @yaxis.frac( ey2 ) ] )
      end
    end
    def bar_plot(dev, x1, y1, x2, y2, style)
      dev.box2( [x1, y1], [x2, y2], style.style, style.closed)
    end
  end

#  sym =[s1,s2,s3,s4.s5.s6,s7,s8,s9]

  class PlotSymbol
    attr_accessor :pstyle
    def initialize( pstyle )
      @pstyle = pstyle.dup
    end
    def plot(dev, v, factor = 1.0)
      dev.send(@pstyle.shape, v, @pstyle.closed, @pstyle.style, factor)
    end
  end

  class Axis
    attr_accessor :title, :titlepos, :titleangle, :title_show
    attr_accessor :origin, :vect, :tickvect
    attr_accessor :show, :ticklabel_show, :mirror, :thick
    attr_accessor :tick_show, :tickthick, :ticklen
    attr_accessor :mtick_show, :mtickthick, :mticklen
    attr_accessor :labeloffset, :labelformat, :labeljust
    attr_accessor :part_show, :part
    attr_reader   :ticks, :mticks
    attr_reader   :max, :min, :range
    attr_accessor :withdata
    attr_reader   :range_specify, :tick_specify
    attr_accessor :logscale

    def initialize( as )

      @title, @titlepos, @titleangle, @title_show = as.title, as.titlepos, as.titleangle, as.title_show
      @origin, @vect, @tickvect = as.origin, as.vect, as.tickvect
      @show, @ticklabel_show, @mirror, @thick = as.show, as.ticklabel_show, as.mirror, as.thick
      @tick_show, @tickthick, @ticklen = as.tick_show, as.tickthick, as.ticklen
      @mtick_show, @mtickthick, @mticklen = as.mtick_show, as.mtickthick, as.mticklen
      @labeloffset, @labelformat, @labeljust = as.labeloffset, as.labelformat, as.labeljust
      @part_show, @part = as.part_show, as.part

      @withdata = false   # is this axis related to data?
      @logscale = false   # default is normal plot
      
      @range_specify = false # range is specified?
      @min, @max = nil, nil

      self.range = as.range

      @tick_specify = false # ticks is specified?
      @mtick_specify = false # ticks is specified?

      @step = nil
      @mstep = nil

      @vwidth = nil
      @logvwidth = nil
      @logmin = nil
      
      @text = []  # to keep the string to be drawn

      @proc_label = lambda{|labelformat, v| sprintf(labelformat, v)}
    end

    def frac( x )
      if !@logscale
        (x - @min) / (@max - @min)
      else
        if max <=0.0 || min <= 0.0 then
          print "#{max}, #{min}\n"
        end
        if x > 0 then 
          (log10(x) - log10(@min)) / (log10(@max) - log10(@min))
        else
          0.0
        end
      end
    end

    def range=(r)
      if r == nil then
	@range_specify = false
	@min, @max = nil, nil
      elsif r.class == Array && r.size == 2 
	@range = r
	@min,@max = r.min, r.max
	@range_specify = true
	@tick = nil unless tick_specify
      else
	raise "range should be [min,max]"
      end
    end
 
    def ticks=(ti)
      if ti == nil 
	@ticks = nil
	@tick_specify = false
      else
	@ticks = ti
	@tick_specify  = true
      end
    end

    def mticks=(mticks)
      if mticks == nil 
	@mticks = nil
	@mtick_specify = false
      else
	@mticks = mticks
	@mtick_specify  = true
      end
    end

    def minmaxdeterm(min, max, step, mstep, steps, msteps)

      if step != 0 then
        tunit = 10**(log10(step).floor)
      else
        tunit = 1.0
      end
      dmin = tunit * 10.0
      smin = 0.0

      steps.each_with_index { |s, index|
        distance = tunit * s - step
        distance = - distance if 0.0 > distance
        if distance < dmin then
          smin = s
          dmin = distance
          mstep = msteps[index]
        end
      }

      step = tunit * smin

      amin = (min / step ).to_i * step
      amax = ((max / step ).to_i + 1)* step
      if amax+step <= max then
        amax += step
      end
      [amin, amax, step, mstep]
    end
    def proc_label(&proc)
      @proc_label = proc
    end
    def set_ticks(vticks)
      #
      #set steps
      #
      @ticks = vticks.collect{|v|
#        [v, sprintf(@labelformat, v) ]
         [v, @proc_label.call(@labelformat, v)]
      }
    end
    def set_mticks(min, max, ntick, vticks, step, mstep)
      delta = step / mstep
      @mticks = (-mstep .. (ntick + 1) * mstep).collect {|n|
        v = @min + n * delta
      }
    end

#    def determticks(step, mstep, min = @min, max = @max, logscale = nil)
    def determticks(step, mstep, min, max, logscale = nil)
      steps = [1.0, 2.0, 5.0]
      msteps = [10, 2, 5]
      if ! @logscale then
        #Linear Scale
        step = (max - min) / 5.0
        amin, amax, step, mstep = minmaxdeterm(min, max, step, mstep, steps, msteps)
        print "step = #{step}\n" if $debug

#        print "range_specify #{@range_specify}\n"
        if @range_specify == false then
          @min, @max = amin, amax
          @range_specify = true
        end
#        print "amin = #{amin}, amax = #{amax}\n"
#        print "min = #{@min}, max = #{@max}\n"
        if ! @tick_specify then
          ntick = ( (@max - @min) / step).to_i
          vticks = (0 .. ntick).collect{ |i| @min + i * step }
          set_ticks(vticks)
          set_mticks(@mix, @max, ntick, vticks, step, mstep)
          @step, @mstep = step, mstep
        end

      else
        #logscale

        if min <= 0.0 || max <= 0.0 then
          dif = 0.0
        else
          dif = (log10(max) - log10(min)).floor
        end  
        print "max = #{max}, min = #{min}\n" if $debug
        print "dif=#{dif}\n" if $debug
        case dif
        when 0
          amin, amax, step, mstep = minmaxdeterm(min, max, step, mstep, steps, msteps)
          if ! @range_specify then
            @min, @max = amin, amax
            @range_specify = true
          end
          if ! @tick_specify then
            ntick = ( (@max - @min) / step).to_i
            vticks = (0 .. ntick).collect{ |i| @min + i * step }
            set_ticks(vticks)
            @step, @mstep = step, mstep
          end
        when 1 .. 9 # Tick:10^n, mtick = 2~9
          if ! @range_specify then
            @min = 10**(log10(min).floor)
            @max = 10** (log10(max).floor + 1)
            @range_specify = true
          else
#            @min, @max = min, max
          end
          ntick = log10(@max).floor - log10(@min).ceil
          step = 10
          mstep = 1
          
          vticks = (0 .. ntick).collect{|i| 10**(log10(@min).ceil + i) }
          set_ticks(vticks)
          @mticks = []
          (0 .. ntick).each{ |i| (2 .. 9).each{|j| @mticks.push(10**(log10(@min).floor + i) * j) } }
        else  ## Tick:10^n upto 5 in number , mtick = else 
          nskip = (dif / 5.0).floor + 1
          if ! @range_specify then
            @min = 10**(log10(min).floor)
            @max = 10**(log10(max).floor + 1)
#            @range_specify = true
          end

          nst = log10(@min).ceil
          nen = log10(@max).floor
          vticks = []
          @mticks = []
          (nst .. nen).each{|i|
            if (i - nst) % nskip == 0 then
              vticks.push(10**i)
            else
              @mticks.push(10**i)
            end
            set_ticks(vticks)
          }
        end
      end
    end
      # shortcut for calculating frac

    def setwidth
      if @max != nil && !min !=nil then
      @vwidth = @max - @min
      if @min > 0.0 then 
        @logmin = log10(@min)
        if @max > 0.0 then
          @logwidth = log10(@max) - log10(@min)
        end
      end
      end
    end
    
    def plot( dev )
      unless @show then return end

      style = dev.style
      style.width = @thick
      dev.line( [@origin[0], @origin[1]], 
	        [@origin[0] + @vect[0], @origin[1] + @vect[1]] , style)

      if @step == nil then
#determticks(1.0, 10.0, 0, 1)
      end

      print "min, max=", @min, ",   ", @max, "\n" if $debug
      print "min, max=", sprintf("%e", @min), ",   ", sprintf("%e", @max), "\n" if $debug

      pticks =  @ticks.collect{ |t| frac(t[0]) }

      pticks.each_with_index { |p, i|
	if ticks[i][0] >= @min and ticks[i][0] <= @max
	  x = @origin[0] + p * @vect[0]
	  y = @origin[1] + p * @vect[1]
#          print "x = #{x}, y = #{y}\n"
          dev.line( [x, y], 
		   [x +  @ticklen * @tickvect[0] , y + @ticklen * @tickvect[1]]) 

	  str = @ticks[i][1]
	  if @ticklabel_show  then
	    @text.push( Text.new(str, [x, y], @labeljust, @labeloffset ) )
	  end
	end
      }

      if @mtick_show && @mticks != nil then
#        p @mticks
	pmticks = @mticks.collect{ |v| frac(v) }
	pmticks.each_with_index { |p, j|
	  if @mticks[j] > @min && @mticks[j] < @max then 
	    x = @origin[0] + p * @vect[0]
	    y = @origin[1] + p * @vect[1]
	    dev.line( [x, y], 
             [x +  @mticklen * @tickvect[0] , y + @mticklen * @tickvect[1]]) 
           end
	}
      end

      if @title_show then
	@text.push( Text.new(@title, @titlepos, 'c', [0,0] ,@titleangle) )
      end

      @text.each{ |t| t.plot(dev) }
    end
=begin
    def method_missing(methid, args)
      printf("%s is not the chractreisitcs of class Axis\n", methid.id2name)
    end
=end
  end

  class Legend
    attr_accessor :texts, :style
#    @nl = 0
#    @@offset1 = [0.0, 0.0] # 
#    @@offset2 = [0.0, 0.0] #
    def initialize( style = Ogre::Std_legendstyle[0] )
      @style = style
      @draws = []
      @texts = []
      @nl = 0
      @maxlen = 0
    end

    def add( prc, text )
      @draws.push( prc )
      @texts.push(text)
      if text != nil && text.length > @maxlen then
# temporaly
        @maxlen = text.length
      end
      @nl += 1
    end

    def plot(dev)
      x1 = @style.pos1[0] 
      y1 = @style.pos1[1]
      x2 = @style.pos2[0] 
      y2 = @style.pos2[1]
      dx = dy = @style.size
      inc = @style.inc

      if @style.box_show then
	bx1 = x1 - dx
	by1 = y1 + dy
	bx2 = x2 + Text.ew * @maxlen 
	by2 = y1 + ( @nl ) *  inc[1] 

	dev.box2( [bx1, by1], [bx2, by2], @style.style, @style.background_show )
      end
      for i in (0 .. @nl - 1)
	x = x1 
	y = y1 + inc[1] * i

        @draws[i].each{|pr| pr.call( dev, x, y, dx, dy ) }

	x = x2 
        y = y2 + inc[1] * i - Text::eh * 0.5
#	temp = Text.new(@texts[i], [x, y], 'L', [0.0, -0.5], 0 )
#	temp.plot(dev)
	dev.putchar(@texts[i], [x, y])
      end
    end
  end

  class Text
    @@ew = @@eh = 0
    attr_accessor :v
    def initialize(str, v, just, offset = [0.0, 0.0], rot = 0, font = nil)
      @str = str
      @v = v
      @just = just
      @offset = offset
      @rot = rot
      @font = font
    end

    def Text.ewehset(ew, eh)
      printf("ew = %f eh = %f\n", ew, eh) if $debug
      @@ew = ew
      @@eh = eh
    end

    def Text.ew
      @@ew
    end

    def Text.eh
      @@eh
    end

    def plot(dev)
      dev.putchar(@str, [@v[0] + @offset[0] * @@ew, 
                         @v[1] + @offset[1] * @@eh], @just, @rot, @font)
    end
    def method_missing(methid, args)
      fprintf(stderr, "%s is not the chractreisitc of class Graph\n", methid.id2name)
    end
  end

  class Line
    attr_accessor :v1, :v2
    def initialize(v1, v2, arrow=[false, false], style=nil)
      @v1 = v1
      @v2 = v2
      @arrow = arrow
      @style = style
    end
    def plot(dev)
      dev.line(@v1, @v2, @style)
      if @arrow.kind_of?(Array) then
	if @arrow[0] then # at the beginning
	  plot_arrow(dev, @v2, @v1, Ogre::Std_arrowstyle[0])
	end
	if @arrow[1] then # a the end
	  plot_arrow(dev, @v1, @v2, Ogre::Std_arrowstyle[0])
	end
      end
    end

    def plot_arrow(dev, v1, v2, astyle)
      length = 1.0 / sqrt( (v2[0] - v1[0]) ** 2 + (v2[1] - v1[1]) ** 2) * astyle.size
      uv1 = [ (v2[0] - v1[0] ) * length, (v2[1] - v1[1]) * length ]
      uv2 = [ uv1[1], -uv1[0] ]
      vect = []
      astyle.rpos.each{|rp|
	vect.push( [v2[0] + uv1[0] * rp[0] + uv2[0] * rp[1], v2[1] + uv1[1] * rp[0] + uv2[1] * rp[1] ] )
      }
      puts "arrow vect\n" if $debug

      dev.multiline(vect, astyle.style)
	
    end
  end
end
end


=begin
$Id: defs.rb,v 1.22 2008/11/11 12:38:14 ohdachi Exp $
=end
$debug = false
module Ogre

#
# Definitions of default style of lines (color, width, dash, background)
#                default style of fonts (fontname, size)
#

  Style = Struct.new("Style", :color, :width, :linestyle, :background)
  Font = Struct.new("Font", :name, :size)

  Std_style = Style.new(Color::Black, 1.0, [ 0 ],  Color::White)
  Std_font = Font.new("/Helvetica", 14)

#
# Definitions of symbols (shape, open/close, dash, size)
#  names of method of Device is specified in shape.
#
  Plotstyle = Struct.new("Plotstyle", :shape, :closed, :style, :size)
  
  Std_plotstyle = [
     Plotstyle.new( "sym_circle", false, 
                     Style.new( Color::Black, 1.0, [0], Color::White), 1),

     Plotstyle.new( "sym_square", true, 
                     Style.new( Color::Blue, 1.0, [3, 3], Color::White), 1),

     Plotstyle.new( "sym_triangle", false, 
                     Style.new( Color::Red, 1.0, [1, 1], Color::White), 1),

     Plotstyle.new( "sym_cross", true, 
                     Style.new( Color::Green, 1.0, [3, 1, 1, 1], Color::White), 1),

     Plotstyle.new( "sym_diamond", false, 
                     Style.new( Color::Black, 2.0, [0], Color::White), 1),

     Plotstyle.new( "sym_circle", true, 
                     Style.new( Color::Blue, 2.0, [3, 3], Color::Purple),1),

     Plotstyle.new( "sym_plus", false, 
                     Style.new( Color::Red, 2.0, [1, 1], Color::White), 1),

     Plotstyle.new( "sym_triangle_reverse", true, 
                     Style.new( Color::Green, 2.0, [3, 1, 1, 1], Color::White),1),

     Plotstyle.new( "sym_circle", false, 
                     Style.new( Color::Black, 1.0, [3, 3], Color::White), 1),

     Plotstyle.new( "sym_circle", false,
                     Style.new( Color::Black, 1.0, [1, 1], Color::White), 1),

     Plotstyle.new( "sym_circle", false, 
                     Style.new( Color::Black, 1.0, [3, 1, 1, 1], Color::White), 1)

   ]

  Bar_Style= [
         Plotstyle.new( "bar0", true, 
                     Style.new( Color::White, 1.0, [0], Color::Blue), 1),
         Plotstyle.new( "bar1", true, 
                     Style.new( Color::White, 1.0, [0], Color::Red), 1),
         Plotstyle.new( "bar2", true, 
                     Style.new( Color::White, 1.0, [0], Color::Green), 1),
         Plotstyle.new( "bar3", true, 
                     Style.new( Color::White, 1.0, [0], Color::Purple), 1),
         Plotstyle.new( "bar4", true, 
                     Style.new( Color::White, 1.0, [0], Color::Yellow), 1),
         Plotstyle.new( "bar5", true, 
                     Style.new( Color::White, 1.0, [0], Color::Magenta), 1),
         Plotstyle.new( "bar6", true, 
                     Style.new( Color::White, 1.0, [0], Color::Gold), 1),
         Plotstyle.new( "bar7", true, 
                     Style.new( Color::White, 1.0, [0], Color::White), 1),
         Plotstyle.new( "bar8", true, 
                     Style.new( Color::Blue, 1.0, [0], Color::Blue), 1),
         Plotstyle.new( "bar9", true, 
                     Style.new( Color::Red, 1.0, [0], Color::Red), 1),
         Plotstyle.new( "bar10", true, 
                     Style.new( Color::Green, 1.0, [0], Color::Green), 1),
         Plotstyle.new( "bar11", true, 
                     Style.new( Color::Purple, 1.0, [0], Color::Purple), 1),
         Plotstyle.new( "bar12", true, 
                     Style.new( Color::Yellow, 1.0, [0], Color::Yellow), 1),
         Plotstyle.new( "bar13", true, 
                     Style.new( Color::Magenta, 1.0, [0], Color::Magenta), 1),
         Plotstyle.new( "bar14", true, 
                     Style.new( Color::Gold, 1.0, [0], Color::Gold), 1),
         Plotstyle.new( "bar15", false, 
                     Style.new( Color::Black, 1.0, [0], Color::White), 1),
         Plotstyle.new( "bar16", true, 
                     Style.new( Color::Black, 1.0, [0], Color::Black), 1),
    ]
#
# Constants for plot style
#

Scatter = 1
Line = 2
XError = 4
YError = 8
Bar = 16
STACK = 32
Dummy = 128

#
# default symbol and line
#

#  0 open    circle           black     plain
#  1 closed  square           blue      dashed
#  2 open    triangle         red       dotted
#  3 closed  cross            green     double dashed
#  4 open    diamond          black     
#  5 closed  circle           blue
#  6 open    plus             red
#  7 closed   reverse_triangle green

  Axisstyle = Struct.new("Axisstyle", :instancename, 
                         :title, :titlepos, :titleangle, :title_show, :range,
			 :origin, :vect, :tickvect, 
                         :show, :ticklabel_show, :mirror, :thick,
                         :tick_show, :tickthick, :ticklen, 
                         :mtick_show, :mtickthick, :mticklen,
                         :labeloffset, :labelformat, :labeljust, 
                         :part_show, :part)
#
#Axis are x, y, x2, y2, x3, y3
#

Std_axisstyle = [

    Axisstyle.new("xaxis=", "xtitle", [0.5, -0.2], 0, true, nil,
		   [0.0, 0.0],  [1.0, 0.0], [0.0, 1.0], 
		   true, false, 2, 1.5, 
                   true, 1.0, 0.02, 
                   true, 1.0, 0.01,
                   [0, -1.4], '%g', 'c', 
                   false, [0,1] ),

    Axisstyle.new( "yaxis=", "ytitle", [-0.15, 0.5], 90, true, nil,
		  [0.0, 0.0], [0.0, 1.0], [1.0, 0.0],
		  true, false, 3, 1.5, 
                  true, 1.0, 0.02, 
                  true, 1.0, 0.01,
                   [-0.5, -0.5], '%g', 'r',
                   false, [0,1] ),

    Axisstyle.new("x2axis=", "x2title", [0.5, 1.1], 0, false, nil,
		  [0.0, 1.0], [1.0, 0.0], [0.0, -1.0], 
		  true, false, 0, 1.5, 
                  true, 1.0, 0.02,
                  true, 1.0, 0.01,
                   [0, 0.4], '%g', 'c',
                   false, [0,1] ),

    Axisstyle.new("y2axis=", "y2title", [1.15, 0.5], 270, false, nil,
		  [1.0, 0.0], [0.0, 1.0], [-1.0, 0.0], 
		  true, false, 1, 1.5, 
                  true, 1.0, 0.02,
                  true, 1.0, 0.01,
                   [0.5, -0.5], '%g', 'l',
                   false, [0,1] ),

    Axisstyle.new("x3axis=", "x3title", [0.5, -0.4], 0, false, nil,
		  [0.0, -0.2], [1.0, 0.0], [0.0, 1.0],
		  false, true, nil, 1.0, 
                  true, 1.0, 0.02,
                  true, 1.0, 0.01,
                   [0, -1.4], '%g', 'c',
                   false, [0,1] ),

    Axisstyle.new("y3axis=", "y3title", [-0.3, 0.5], 90, false, nil,
		  [-0.2, 0.0], [0.0, 1.0], [1.0, 0.0], 
		  false, true, nil, 1.0, 
                  true, 1.0, 0.02,
                  true, 1.0, 0.01,
                   [-0.5, -0.5], '%g', 'r',
                   false, [0,1] ),

    Axisstyle.new("x4axis=", "x4title", [0.5, 1.4], 0, false, nil,
		  [0.0, 1.2], [1.0, 0.0], [0.0, -1.0],
		  false, true, nil, 1.0, 
                  true, 1.0, 0.02,
                  true, 1.0, 0.01,
                   [0, 0.4], '%g', 'c',
                   false, [0,1] ),

    Axisstyle.new("y4axis=", "y4title", [1.3, 0.5], 270, false, nil,
		  [1.2, 0.0], [0.0, 1.0], [-1.0, 0.0], 
		  false, true, nil, 1.0, 
                  true, 1.0, 0.02,
                  true, 1.0, 0.01,
                   [0.5, -0.5], '%g', 'l',
                   false, [0,1] ),

    ]

#  Bg = Style.new( [255, 255, 255], 1.0, [0], [255, 255, 210] )
  Bg = Style.new( [255, 255, 255], 1.0, [0], [255, 255, 255] )

  Legendstyle = Struct.new("Legendstyle", :pos1, :pos2, :size, :inc, :style, :box_show, :background_show)
  
  Std_legendstyle = [
    Legendstyle.new( [0.1,  0.8], [0.2, 0.8], 0.075, [0, -0.1], Style.new( Color::Black, 1.0, [0], Color::White), true, true ),
    Legendstyle.new( [0.6,  0.8], [0.7, 0.8], 0.075, [0, -0.1], Style.new( Color::Black, 1.0, [0], Color::White), true, true ),
    Legendstyle.new( [0.6,  0.3], [0.7, 0.3], 0.075, [0, -0.1], Style.new( Color::Black, 1.0, [0], Color::White), true, true ),
    Legendstyle.new( [0.1,  0.3], [0.2, 0.3], 0.075, [0, -0.1], Style.new( Color::Black, 1.0, [0], Color::White), true, true )
  ]

  Legend_shortcut = { 'left top' => 0, 'lt' => 0, 'tl' => 0, 0 => 0, 
                      'right top' => 1, 'rt' => 1, 'tr' => 1, 1 => 1,
                      'right bottom' => 2, 'rb' => 2, 'br' => 2, 2 => 2, 
                      'left bottom' => 3, 'lb' => 3, 'bl' => 3, 3 => 3
  }


#
# arrow style
#

  Arrowstyle = Struct.new("Arrowstyle", :rpos, :size, :style, :closed)

  Std_arrowstyle = [
    Arrowstyle.new([[0.0, 0.0], [-1.0, -0.5], [-1.0, 0.0], [-1.0, 0.5], [0.0, 0.0]], 0.02, Style.new(Color::Black, 1.0, [0], Color::Black), true)
  ]

#
# image array
#
  Color_pallet = []
  cp = []
  0.upto(255){|i| cp.push(Style.new([i, i, i], 1.0, [0], [i, i, i]) ) }
  Color_pallet.push(cp)
  cp = []
  255.upto(0){|i| cp.push(Style.new([i, i, i], 1.0, [0], [i, i, i]) ) }
  Color_pallet.push(cp)
end

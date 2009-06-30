require 'graph.rb'
require 'vrcanvas.rb'
require 'drb/drb'
require 'canvas.rb'
require 'readfile.rb'
require '../iread_ruby/readana.rb'

dir = 'x:\\sdc_data\\'
odir = 'c:\\tansxdoc\\20070621-IDBSDC_ws\\'
def determ_color(value)
    color = Color::White
    case value
    when (200 ... 400)
      color = Color::Blue
    when (400 ... 600)
      color = Color::Green
    when (600 ... 800)
      color = Color::Red
    when (800 ... 1000)
      color = Color::Yellow
    end
    color
end

test = Readana.new('x:\\nbi@69343.dat')
nbi_exist = (0 .. 30).collect{Array.new(6, 0.0)}
nbi_exist.each_with_index{|r, i| r[0] = i.to_f * 0.1}
test.data.each{|r|
  nt = Integer(r[0] * 10.0)
  (1 .. 5).each{|i|
    if nt < 30 && r[i].to_f > 0.0 then nbi_exist[nt][i] = 1.0 end
    }
}


#p nbi_exist

xrange = [1.0, 6.0]

test1 = (0 .. 100).collect{|i| [i.to_f/10.0 - 0.1, i.to_f / 10.0, i.to_f / 10.0 + 0.1, Math::sin(i.to_f / 10.0)]}
test2 = (0 .. 100).collect{|i| [i.to_f / 10.0, Math::cos(i.to_f / 10.0)]}
test3 = (0 .. 100).collect{|i| [i.to_f / 10.0, Math::cos(i.to_f / 10.0)**2.0]}


g1 = Graph.new(test1, [0,1], 2, :gtype => Ogre::Line) 
g1.add(test2, 0, 1)
g1.y2axis.range = [-2, 2]
g1.add(test3, 0, 1, :axis1 => 0, :axis2 => 5)
#1.y3axis.range = [-2, 2]
g1.x4axis.show = true

#g2 = Graph.new(test2, [0, 1], 2, :gtype => Ogre::Bar){|r| [r[0], 0.02, r[1]]}
#g2 = Graph.new(nbi_exist, [0, 1], [1, 2], :gtype => Ogre::Scatter){|r| [r[0], 0.1, 0.0, r[1] ]}
#g2.add(nbi_exist, [0, 1], [1, 2], :gtype => Ogre::Scatter){|r| [r[0], 0.1, 0.5, r[2] + 0.5]}
#g2.add(nbi_exist, [0, 1], [1, 2], :gtype => Ogre::Scatter){|r| [r[0], 0.1, 1.0, r[3] + 1.0]}

g2 = Graph.new(nbi_exist, [0,1,2], [3,4], :gtype => Ogre::Bar){|row| [row[0], row[0], row[0]+0.2, 0.5, row[2]] }


g2.xaxis.range = [0, 3]
g2.yaxis.range = [-0.1, 2]

PSCanvas.new('test.ps') do |ps|
  ps.setpart([0.1, 0.1], [0.95, 0.45])
  g2.plot(ps)
end

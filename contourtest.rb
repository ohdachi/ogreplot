require 'graph'

data = (0 .. 99).collect{|i| Array.new(100)}
(0 .. 99).each{|i|
  (0 .. 99).each{|j|
    data[j][i] = Math::exp( - ((i.to_f/10.0 - 4.5)**2 + (j.to_f/10.0 - 4.5)**2)/2.0 ) * Math::sin( Math::atan2(j.to_f/10.0-4.5, i.to_f/10.0-4.5) * 3)
  }
}

xarr = (0 .. 99).collect{|i| i.to_f/10.0}
yarr = (0 .. 99).collect{|i| i.to_f/10.0}
c = Graph.new(data, 0, 1, :gtype => Ogre::Contour, :levels => [-0.05, -0.01, 0.01, 0.05, 0.1, 0.2, 0.3], :xarr => xarr, :yarr => yarr )
c.xaxis.range = [50, 60]

c2 = Graph.new('x:/temp.dat', 0, 1, :gtype => Ogre::Contour, :levels => [20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0] )
PSCanvas.new('test.ps') do |ps|
  ps.setpart [0.1, 0.1], [0.9, 0, 4]
#  c.plot(ps)
  ps.setpart [0.1, 0.5], [0.9, 0.8]
  c2.plot(ps)
end
  

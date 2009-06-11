require 'graph.rb'
require 'canvas.rb'
require 'vrcanvas.rb'
require 'drb/drb'

data = []
(0 .. 100).each{|i|
  data[i] = [i.to_f/10.0, sin(i.to_f/10.0) + 0.2]
}
#  g1 = Graph.new(data, 0, 1, 0, 1, Scatter, 4, [0, 10], [-1, 1])
  g1 = Graph.new(data, 0, 1)

  p = PSCanvas.new
  g1.plot(p)

  vr = DRbObject.new_with_uri('druby://localhost:3010')
  p vr
  v = VRCanvas.new(vr)
  g1.plot(v)

=begin
  (0 .. 100).each{|i|
  data[i] = [i.to_f/10.0, cos(i.to_f/10.0) * 0.5]
}
  g2 = Graph.new(data, 0, 1)
  g2.plot(v)
=end
  
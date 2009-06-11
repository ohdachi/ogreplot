require 'graph.rb'
require 'drb/drb'
require 'vrcanvas.rb'


vr = DRbObject.new_with_uri('druby://localhost:3010')

g = Graph.new([[0.0, 0.0], [0.1, 1.0]], 0, 1)
g2 = Graph.new([[0.0, 0.0], [0.1, 0.5]], 0, 1, :symtype => 1)

VRCanvas.new(vr) do |v|
  g.plot(v)
end

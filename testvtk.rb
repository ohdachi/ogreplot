$LOAD_PATH.push('../ogreplot')
require 'graph.rb'
require 'canvas.rb'
require 'vtkcanvas.rb'

a = [1,2,3,4,5]
b = [3,4,5,6,7]

g = Graph.new(a.zip(b), 0, 1)
VTKCanvas.new('test.vtk') do |fn|
  g.plot(fn)
end

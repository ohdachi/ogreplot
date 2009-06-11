$LOAD_PATH.push('c:/home/projects/ogre')


  require 'graph.rb'
  data = [ [0, 0], [1,10], [2, 20] ]
  g = Graph.new(data, 0, 1)
  PSCanvas.new('graph1.ps') do |ps|
    g.plot(ps)
  end


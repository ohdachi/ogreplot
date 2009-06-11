$LOAD_PATH.push('c:/home/projects/ogre')


  require 'graph.rb'
  data1 = [ [0.0, 0.0], [1.0,10.0], [2.0, 20.0] ]
  data2 = [ [0.0, 10.0], [1.0,5.0], [2.0, 3.0] ]
  g1 = Graph.new(data1, 0, 1, :xrange => [-1, 5], :yrange => [-5, 30])
  g2 = Graph.new(data2, 0, 1, :xrange => [-1, 5], :yrange => [-5, 30])
  PSCanvas.new('graph11.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.45, 0.5])
    g1.plot(ps)
    ps.setpart([0.6, 0.1], [0.95, 0.5])
    g2.plot(ps)
  end


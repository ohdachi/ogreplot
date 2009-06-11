$LOAD_PATH.push('c:/home/projects/ogre')

  require 'graph.rb'
  data = [ [0.0, 0.0, 1.0], [1.0,10.0,11.0], [2.0, 20.0, 22.0] ]

  g = Graph.new(data, 0, [1, 2], :xrange => [-1, 5], :yrange => [-5, 30], :label => ['plot1', 'plot2'])
  g.legend_show = true
  PSCanvas.new('graph9.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.5])
    g.plot(ps)
  end


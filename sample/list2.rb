$LOAD_PATH.push('c:/home/projects/ogre')


  require 'graph.rb'
  g = Graph.new('data1.txt', 0, 1, :gtype => Ogre::Line )
  PSCanvas.new('graph2.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.5])
    g.plot(ps)
  end


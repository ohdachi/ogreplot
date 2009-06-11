$LOAD_PATH.push('c:/home/projects/ogre')

  require 'graph.rb'
  g = Graph.new('data1.txt', 0, 1, :gtype => Ogre::Line | Ogre::Scatter, :yrange => [-2, 2], :xrange => [0, 10], :symtype => 1) 
  g.yaxis.labelformat = "%4.2f"
  PSCanvas.new('graph7.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.5])
    g.plot(ps)
  end


$LOAD_PATH.push('c:/home/projects/ogre')


  require 'graph.rb'
  g = Graph.new('data1.txt', 0, [1,2,3], :gtype => Ogre::Line, :yrange => [-2, 2], :xrange => [0, 10] ) {|c|
      [ c[0], c[1], c[1] + 1.0, Math::cos(c[0]) ** 2 ] 
  }
  PSCanvas.new('graph4.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.5])
    g.plot(ps)
  end


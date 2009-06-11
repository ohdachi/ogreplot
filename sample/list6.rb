$LOAD_PATH.push('c:/home/projects/ogre')

  require 'graph.rb'
  data = []
  (1 .. 10).each{|i|
     one = [i.to_f]
    (0 .. 7).each{|j|
      one.push(j.to_f)
    }
    data.push(one)
  }

  g = Graph.new(data, 0, [1,2,3,4,5,6,7,8], :gtype => Ogre::Line | Ogre::Scatter, :yrange => [-1.0, 8.0], :xrange => [0, 11])

  PSCanvas.new('graph6.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.5])
    g.plot(ps)
  end


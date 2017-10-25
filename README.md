# ogreplot
ruby library for scientific plotting. (OGRE:Object-oriented Graph plotting library in Ruby Environment)
In this library, each graph is represented as ruby object. Control of the elements of graph, such as axis, ticks are easily controlled.
Mainly used for postscript files for scientific Journals. 

#sample
    requre 'ogreplot/graph'
    g = Graph.new(prof1, 0, [1, 2], :gtype => Ogre::Scatter|Ogre::YError, :xrange => xrange, :yrange => [0, yrange[0]], :label => "#{sn1} (#{nt1/1000}s)")
    g.xaxis.title = "R [m]"
    g.xaxis.labelformat = '%4.1f'
    PSCanvas.new(outputfile) do |ps|
      ps.setpart([0.1, 0.1], [0.9, 0.5])
      g.plot(ps)
    end



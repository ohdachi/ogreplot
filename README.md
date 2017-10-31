# ogreplot
ruby library for scientific plotting. (OGRE:Object-oriented Graph plotting library in Ruby Environment)
In this library, each graph is represented as ruby object. Control of the elements of graph, such as axis, ticks are easily controlled.
Mainly used for postscript files for scientific Journals. 

# ogre: 
## Object oriented Graph plot program on Ruby environment
### Programed by Satoshi Ohdachi ( Ohdachi@nifs.ac.jp )
###    ver 0.01 Dec. 2000
###    ver 0.1 Aug. 2007
###    ver 1.0 Jun. 2009 registered to Google Code
###    2012 moveto Github since Google Code is closed.

#sample
```sample.rb
    requre 'ogreplot/graph'
    g = Graph.new(prof1, 0, [1, 2], :gtype => Ogre::Scatter|Ogre::YError, :xrange => xrange, :yrange => [0, yrange[0]], :label => "#{sn1} (#{nt1/1000}s)")
    g.xaxis.title = "R [m]"
    g.xaxis.labelformat = '%4.1f'
    PSCanvas.new(outputfile) do |ps|
      ps.setpart([0.1, 0.1], [0.9, 0.5])
      g.plot(ps)
    end
```

### Acknowledgemtns
Thank you very much SakaN san for stroke font KST32B http://www.vector.co.jp/soft/data/writing/se119277.html.
KST32B is used for generating vtk file. 

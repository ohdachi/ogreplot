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

  g = Graph.new(data, 0, [1,2,3], :gtype => Ogre::Line | Ogre::Scatter, :yrange => [-1.0, 6.0], :xrange => [0, 11], :label => ['plot1', 'plot2', 'plot3'])

  g.legend_show = true
  g.legend.style.pos1 = [0.1, 0.9]
  g.legend.style.pos2 = [0.15, 0.9]
  g.legend.style.inc = [0.0, -0.05]

  g.xaxis.title = 'xaxis'
  g.x2axis.title = 'x2axis'
  g.x3axis.title = 'x3axis'
  g.x4axis.title = 'x4axis'
  g.yaxis.title = 'yaxis'
  g.y2axis.title = 'y2axis'
  g.y3axis.title = 'y3axis'
  g.y4axis.title = 'y4axis'
  
  g.x2axis.title_show = true
  g.x3axis.title_show = true
  g.x4axis.title_show = true
  g.y2axis.title_show = true
  g.y3axis.title_show = true
  g.y4axis.title_show = true


  g.y4axis.show = true
  g.x3axis.show = true
  g.x4axis.show = true
  g.y3axis.show = true
  g.y4axis.show = true

  g.x3axis.range = [0, 1]
  g.x3axis.ticks = [ [0.0, "0"],[1.0, "1"] ]
  g.x3axis.mticks = [0.5]
  g.x4axis.range = [0, 1]
  g.x4axis.ticks = [ [0.0, "0"],[1.0, "1"] ]
  g.x4axis.mticks = [0.5]
  g.y3axis.range = [0, 1]
  g.y3axis.ticks = [ [0.0, "0"],[1.0, "1"] ]
  g.y3axis.mticks = [0.5]
  g.y4axis.range = [0, 1]
  g.y4axis.ticks = [ [0.0, "0"],[1.0, "1"] ]
  g.y4axis.mticks = [0.5]
  
  PSCanvas.new('sample.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.6])
    g.plot(ps)
  end


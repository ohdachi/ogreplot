$LOAD_PATH.push('c:/home/projects/ogre')

  require 'graph.rb'
  data = [ [0.0, 0.0, 1.0], [1.0,10.0,11.0], [2.0, 20.0, 22.0] ]
  sym1 = Ogre::Plotstyle.new( "sym_circle", false, Style.new( Color::Red, 1.0, [0], Color::Black), 1)
  sym2 = Ogre::Plotstyle.new( "sym_triangle", true, Style.new( Color::Green, 1.0, [0], Color::Black), 1)
  g = Graph.new(data, 0, [1, 2], :xrange => [-1, 5], :yrange => [-5, 30], :symbol => [sym1, sym2])
  PSCanvas.new('graph8.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.5])
    g.plot(ps)
  end


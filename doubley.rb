require 'graph.rb'
require 'canvas.rb'
require 'readfile.rb'

=begin
--- doubley( array1, column1-1, column1-2, array2, coloumn2-1, column2-2, options, &proc )

== usage
: Simple double y plot
g1 = Graph.new(data, c1, c2, 0, 1, :gtype => Ogre::Scatter, :symtype => 4)
       * plot data[*][c1], data[*][c2] with symbol=4

=end

def doubley(data1, x1, y1, data2, x2, y2, options = {}, &proc)

  options1 = {}
  options2 = {}

#  options1['block'] = 0
  options.each{|key, value|

    if /(.*)1/ =~ key.to_s
      options1[$1] = value
    elsif /(.*)2/ =~ key.to_s
      options2[$1] = value
    elsif key.to_s != 'block' then
        options1[key.to_s] = value
      end
  }
  options2['axis1'] = 0
  options2['axis2'] = 3

  if options1['gtype'] & Ogre::Scatter != 0 then
    options1['symtype'] = 0 if options1['symtype'] == nil
    options2['symtype'] = options1['symtype'] + 1 if options2['symtype'] == nil
  end
  if options1['gtype'] & Ogre::Line != 0 then
    options1['symtype'] = 0 if options1['symtype'] == nil
    options2['symtype'] = options1['symtype'] + 1 if options2['symtype'] == nil
  end
  
  if options['block'] == 1 || options[:block] == 1 then
    g = Graph.new(data1, x1, y1, options1, &proc) 
    g.add(data2, x2, y2, options2)
  elsif options['block'] == 2 || options[:block] == 2
#    print "here\n"
    g = Graph.new(data1, x1, y1, options1)
    g.add(data2, x2, y2, options2, &proc)
  else
    g = Graph.new(data1, x1, y1, options1, &proc) 
    g.add(data2, x2, y2, options2, &proc)
  end
    
  g.y2axis.show = true
  g
end

=begin
d1 = [ [0.0, 0.0, 0.0], [1.0, 1.0, 1.0], [2.0, 2.0, 4.0], [3.0, 3.0, 9.0] ]
g = doubley(d1, 0, 1, d1, 0, 2, :gtype1 => Ogre::Scatter )
#g = Graph.new(d1, 0, 1, :gtype => Ogre::Scatter, :symtype => 5 )
g.xaxis.range = [-1, 5]
g.yaxis.range = [0, 10]

PSCanvas.new do |ps|
  ps.setpart([0.1, 0.1], [0.95, 0.45])
  g.plot(ps)
end
=end

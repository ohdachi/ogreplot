fp = File.open('tutorial.rd')
cmdfp = File.open('mkgraph.cmd', 'w')

outp = false
ofp = 0
psfiles = []
while not fp.eof
  line = fp.gets
  if outp && line =~ /\=end/ then
    outp = false
    ofp.close
  end

  if outp then
    ofp.print line
    if line =~ /\'(.*\.ps)\'/ then 
      psfiles.push($1)
    end
  end

  if line =~/^\(\(\<.*list(.*)\>\)\)$/ then
    num = $1.to_i
    outp = true
    ofp = File.open("list#{num}.rb", "w")
    ofp.print "$LOAD_PATH.push('c:/home/projects/ogre')\n\n"
    cmdfp.print "ruby list#{num}.rb\n"
  end
  
end

psfiles.each{ |f|
  cmdfp.print %Q!gswin32c -dBATCH -dNOPAUSE -sDEVICE=bmp256 -sOutputFile=temp.bmp  #{f}\n!
  cmdfp.print %Q!convert -trim temp.bmp "#{f.gsub(/ps/, 'bmp')}"\n!
}

fp.close
cmdfp.close

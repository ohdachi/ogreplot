
@cdb = {}
File.open('KST32B.txt').each_line{|l|
  l.chomp!
  if l[0..1] == '00' then
    @cdb[ l[2..3] ] = l[5 .. -1]
  end
}
o = File.open('font.dat', 'w')
Marshal.dump(@cdb, o)
o.close


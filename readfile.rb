#!/usr/local/bin/ruby
# $id

# ogre.rb 
#   generic class for plotting

class Readfile
  attr_accessor :data
  def initialize(fname, rem='#')
    @fname = fname  # data file name
#    @c1 = c1        # column number for x
#    @c2 = c2        # column numbers for y
#    @skip = skip    # skip @skip lines
#    @every = every  # read every @every line
    @rem = rem      # ignore lines if the line start with rem
#    self.read()
  end

  def status
;    p @fname, @c1, @c2, @skip, @every, @rem
;     p @fname, @rem
  end

  def lineprint
    @file = File.new(@fname)
    @file.each { | line |
      print line
    }
    @file.close
  end

  def write(sep=',')
  end

  def read(pattern=nil,nskip=0,nline=0)
#    print "#{pattern} #{nskip} #{nline}\n"
    @data = []
    @file = File.new(@fname)
    @nline = nline

# if specified, search for patter and skip nskip lines
    if pattern != nil then
#      rpat = Regexp.escape(pattern)
      begin
	line = @file.gets

        if @file.eof? then break end
      end while( pattern !~ line)
    end

    if nskip != 0 then
      (1 .. nskip).each{ line=@file.gets }
    end

    i = 0
    @file.each { | line |
#      print line[0], @rem
      if line[0, 1] != @rem then 
	onearray =[]
	line.scan(/-?\d*\.?\d+(e|E)(\+|\-)?\d+|-?\d*\.\d+|-?\d+\.?/) { |a, b|
#             match to the pattern   99.9E-33, | .23, | 34.
	  onearray.push($&.to_f)
	}

	@data.push( onearray )
	@nline = @nline -1 
        if @nline == 0 then break end
      end
    }
    @file.close
    @data
  end
end


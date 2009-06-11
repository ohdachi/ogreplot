.SUFFIXES:	.rd .html

RD2	=	ruby "c:/NumRu/ruby/bin\rd2"
OPTION	=	--with-part=html:include -r rd/rd2html-lib.rb --with-css=main.css --html-charset=Shift_JIS --html-title=Ogre_Manual
TARGET	=	tutorial.html

all:	$(TARGET)

tutorial.html:	tutorial.rd main.css
	ruby pup.rb
	mkgraph.cmd
	$(RD2) tutorial.rd $(OPTION) > tutorial.html


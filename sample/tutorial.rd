=begin

= Ogre �̎g���� 2008/7 ��ڋ�

Ogre(Object oriented Graph plot program on Ruby environment)��gnuplot�̂悤�ȉȊw�Z�p�v�Z���u�������O���t�v���b�g�v���O�����ŁAruby�̌v�Z���ʂ���y�ɕ\�����邱�Ƃ�ړI�ɂ��Ă���B

= �͂��߂ẴO���t

�ȒP�ȃO���t��`���Ă݂悤

((<list1>))

  require 'graph.rb'
  data = [ [0, 0], [1,10], [2, 20] ]
  g = Graph.new(data, 0, 1)
  PSCanvas.new('graph1.ps') do |ps|
    g.plot(ps)
  end

=end
=begin html
<img src='graph1.bmp' />
=end
=begin

���̗�ł� data�Ƃ����z��Ɋi�[�����f�[�^����g �Ƃ����O���t�I�u�W�F�N�g������āAPSCanvas�Ƃ�����ʂɕ\������Ƃ�����ł��B
g = Graph.new(data, 0, 1)�Ƃ����̂�data�Ƃ����z���0�Ԗڂ̃J������X���A1�Ԗڂ̃J������y���ɂ��ăO���t�I�u�W�F�N�g�����܂��B������

==�@�t�@�C������̓ǂݍ���

���Ƀt�@�C�����f�[�^��ǂݍ���ŕ\�������Ă݂悤�B

((<list2>))

  require 'graph.rb'
  g = Graph.new('data1.txt', 0, 1, :gtype => Ogre::Line )
  PSCanvas.new('graph2.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.5])
    g.plot(ps)
  end

=end
=begin html
<img src='graph2.bmp' />
=end
=begin

�z������Ă������ɁA�O���̃t�@�C�����w�肷��Ύ����I�ɓǂݍ��݂��s���BGraph�����Ƃ��̃I�v�V������
:symbol => hogehoge�@�Ƃ����`�ł��Ăł���B
�����ŐV�����w�肵���̂� :gtype => Ogre::Line �B����̓O���t�^�C�v����^�C�v�ɂ��邱�Ƃ��Ӗ�����B
�O���t�^�C�v��Ogre::Scatter(�U�z�})�AOgre::Line�i���j�̂ق��� XError, YError, Bar������A
:gtype => Ogre::Scatter | Ogre:: XError�Ƃ������悤�� |�@���g���ċ�؂邱�Ƃŕ����w��ł���B
�܂� ps.setpart�͉�ʂ̈ꕔ�Ƀv���b�g���邱�Ƃ��Ӗ�����B���̗Ⴞ�Ɖ�ʂ̍���(0.1, 0.1) ����c����ʂ̉�ʒ����t��(0.9, 0.5)�ɕ\�����Ă���B

==�@�J�����l�̉��Z

���ɂ̓J�����l�Ԃ̉��Z�������Ă݂�Bruby�̃u���b�N������Graph����邱�ƂŃJ�����l�Ԃ̉��Z���ł��A���̌��ʂ��v���b�g���邱�Ƃ��ł���B

((<list3>))

  require 'graph.rb'
  g = Graph.new('data1.txt', 0, [1,2,3], :gtype => Ogre::Line ) {|c|
      [ c[0], c[1], c[1] + 1.0, Math::cos(c[0]) ** 2 ] 
  }
  PSCanvas.new('graph3.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.5])
    g.plot(ps)
  end

=end
=begin html
<img src='graph3.bmp' />
=end
=begin

�u���b�N���ŗ^����ꂽ�e�s�̒l����A���Ƃ��Ƃ̂��̒l�A����ɂP�����������́Acos(x) **2���v�Z���Ă���B

= �����W�̐ݒ�

��̃O���t������ƃ����W�̐ݒ肪���܂��s���Ă��Ȃ��B�����I�Ɏw�肷��ɂ�:xrange, :yrange���̃I�v�V�������w�肷��΂悢�BGraph.new�̂Ƃ���Ŏw�肵�Ȃ��Ă��A���Ƃ�g.xaxis.range = [0.0, 1,0] �Ƃ����悤�ɁA�ʂɎw�肷�邱�Ƃ��ł���B�܂������̃v���b�g��\������ꍇ�ɂ�[1,2,3]�ƕ����̃J�����ԍ����w�肷��΂悢�B

((<list4>))

  require 'graph.rb'
  g = Graph.new('data1.txt', 0, [1,2,3], :gtype => Ogre::Line, :yrange => [-2, 2], :xrange => [0, 10] ) {|c|
      [ c[0], c[1], c[1] + 1.0, Math::cos(c[0]) ** 2 ] 
  }
  PSCanvas.new('graph4.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.5])
    g.plot(ps)
  end

=end
=begin html
<img src='graph4.bmp' />
=end
=begin

=�@�����ڂ̕ύX

== �W���ŗp�ӂ��Ă���V���{���E���C�����g��

�W���ł͉��̃O���t�̂悤�Ȑ��A�V���{����p�ӂ��Ă���B���ʂɎw�肷��Ə��X�ɂ���炪�g�p�����B

((<list6>))
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

=end
=begin html
<img src='graph6.bmp' />
=end
=begin

�v���b�g�^�C�v�����Ă���ɂ́A�ȉ��̂悤��:symtype�Ɏw�肷��΂悢�B�����ł͂P�Ԃ̐���I��ł���B���ꂼ��̒�`��ogre/defs.rb�ɐݒ肵�Ă���B�܂��Ay���̃��x���̕������s���낢�Ȃ̂�format�����Ă��邱�ƂŕύX���Ă݂�B(g.yaxis.labelformat = "%4.2f")�Blist4�Ƃ̍������ė~�����B

((<list7>))
  require 'graph.rb'
  g = Graph.new('data1.txt', 0, 1, :gtype => Ogre::Line | Ogre::Scatter, :yrange => [-2, 2], :xrange => [0, 10], :symtype => 1) 
  g.yaxis.labelformat = "%4.2f"
  PSCanvas.new('graph7.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.5])
    g.plot(ps)
  end

=end
=begin html
<img src='graph7.bmp' />
=end
=begin

== �V���{���E���C���������Œ�`����

((<list8>))
  require 'graph.rb'
  data = [ [0.0, 0.0, 1.0], [1.0,10.0,11.0], [2.0, 20.0, 22.0] ]
  sym1 = Ogre::Plotstyle.new( "sym_circle", false, Style.new( Color::Red, 1.0, [0], Color::Black), 1)
  sym2 = Ogre::Plotstyle.new( "sym_triangle", true, Style.new( Color::Green, 1.0, [0], Color::Black), 1)
  g = Graph.new(data, 0, [1, 2], :xrange => [-1, 5], :yrange => [-5, 30], :symbol => [sym1, sym2])
  PSCanvas.new('graph8.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.5])
    g.plot(ps)
  end

=end
=begin html
<img src='graph8.bmp' />
=end
=begin


���ɂ̓V���{���ƃ��C���������Œ�`������������Ă݂悤�B

= ���W�F���h�̐ݒ�Ƃ��̕\���ʒu

g.legend_show = true�Ŗ}��(���W�F���h)��\���ł���B
((<list9>))
  require 'graph.rb'
  data = [ [0.0, 0.0, 1.0], [1.0,10.0,11.0], [2.0, 20.0, 22.0] ]

  g = Graph.new(data, 0, [1, 2], :xrange => [-1, 5], :yrange => [-5, 30], :label => ['plot1', 'plot2'])
  g.legend_show = true
  PSCanvas.new('graph9.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.5])
    g.plot(ps)
  end

=end
=begin html
<img src='graph9.bmp' />
=end
=begin

= Log Scale

= �V�[�g��ւ̕����̃O���t�̕\��

���Ăɕ��ׂ�ꍇ�B

((<list10>))

  require 'graph.rb'
  data1 = [ [0.0, 0.0], [1.0,10.0], [2.0, 20.0] ]
  data2 = [ [0.0, 10.0], [1.0,5.0], [2.0, 3.0] ]
  g1 = Graph.new(data1, 0, 1, :xrange => [-1, 5], :yrange => [-5, 30])
  g2 = Graph.new(data2, 0, 1, :xrange => [-1, 5], :yrange => [-5, 30])
  PSCanvas.new('graph10.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.9, 0.3])
    g1.plot(ps)
    ps.setpart([0.1, 0.4], [0.9, 0.6])
    g2.plot(ps)
  end

=end
=begin html
<img src='graph10.bmp' />
=end
=begin

�悱�ɕ��ׂ�ꍇ�B

((<list11>))

  require 'graph.rb'
  data1 = [ [0.0, 0.0], [1.0,10.0], [2.0, 20.0] ]
  data2 = [ [0.0, 10.0], [1.0,5.0], [2.0, 3.0] ]
  g1 = Graph.new(data1, 0, 1, :xrange => [-1, 5], :yrange => [-5, 30])
  g2 = Graph.new(data2, 0, 1, :xrange => [-1, 5], :yrange => [-5, 30])
  PSCanvas.new('graph11.ps') do |ps|
    ps.setpart([0.1, 0.1], [0.45, 0.5])
    g1.plot(ps)
    ps.setpart([0.6, 0.1], [0.95, 0.5])
    g2.plot(ps)
  end

=end
=begin html
<img src='graph11.bmp' />
=end
=begin


= ���낢��ȃO���t�̃T���v��
= �ݒ�\�ȃp�����[�^

=end
=begin html
<img src='sample.bmp' />
=end
=begin

=end
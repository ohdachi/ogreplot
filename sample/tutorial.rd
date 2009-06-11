=begin

= Ogre の使い方 2008/7 大舘暁

Ogre(Object oriented Graph plot program on Ruby environment)はgnuplotのような科学技術計算を志向したグラフプロットプログラムで、rubyの計算結果を手軽に表示することを目的にしている。

= はじめてのグラフ

簡単なグラフを描いてみよう

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

この例では dataという配列に格納したデータからg というグラフオブジェクトを作って、PSCanvasという画面に表示するという例です。
g = Graph.new(data, 0, 1)というのはdataという配列の0番目のカラムをX軸、1番目のカラムをy軸にしてグラフオブジェクトを作ります。そして

==　ファイルからの読み込み

次にファイルかデータを読み込んで表示をしてみよう。

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

配列をしてする代わりに、外部のファイルを指定すれば自動的に読み込みを行う。Graphを作るときのオプションは
:symbol => hogehoge　という形でしてできる。
ここで新しく指定したのは :gtype => Ogre::Line 。これはグラフタイプを線タイプにすることを意味する。
グラフタイプはOgre::Scatter(散布図)、Ogre::Line（線）のほかに XError, YError, Barがあり、
:gtype => Ogre::Scatter | Ogre:: XErrorといったように |　を使って区切ることで複数指定できる。
また ps.setpartは画面の一部にプロットすることを意味する。この例だと画面の左下(0.1, 0.1) から縦長画面の画面中央付近(0.9, 0.5)に表示している。

==　カラム値の演算

次にはカラム値間の演算を試してみる。rubyのブロックをつけてGraphを作ることでカラム値間の演算ができ、その結果をプロットすることができる。

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

ブロック内で与えられた各行の値から、もともとのｙの値、それに１をたしたもの、cos(x) **2を計算している。

= レンジの設定

上のグラフを見るとレンジの設定がうまく行っていない。明示的に指定するには:xrange, :yrange等のオプションを指定すればよい。Graph.newのところで指定しなくても、あとでg.xaxis.range = [0.0, 1,0] というように、個別に指定することもできる。また複数のプロットを表示する場合には[1,2,3]と複数のカラム番号を指定すればよい。

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

=　見た目の変更

== 標準で用意してあるシンボル・ラインを使う

標準では下のグラフのような線、シンボルを用意している。普通に指定すると順々にそれらが使用される。

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

プロットタイプをしてするには、以下のように:symtypeに指定すればよい。ここでは１番の青■を選んでいる。それぞれの定義はogre/defs.rbに設定してある。また、y軸のラベルの文字が不ぞろいなのをformatをしてすることで変更してみる。(g.yaxis.labelformat = "%4.2f")。list4との差を見て欲しい。

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

== シンボル・ラインを自分で定義する

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


次にはシンボルとラインを自分で定義するやり方を見てみよう。

= レジェンドの設定とその表示位置

g.legend_show = trueで凡例(レジェンド)を表示できる。
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

= シート上への複数のグラフの表示

たてに並べる場合。

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

よこに並べる場合。

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


= いろいろなグラフのサンプル
= 設定可能なパラメータ

=end
=begin html
<img src='sample.bmp' />
=end
=begin

=end
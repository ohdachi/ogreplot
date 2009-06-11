require 'vr/vrcontrol'
require 'vr/vrhandler'
require 'graph.rb'
#require 'canvasvr.rb'
require 'vrcanvas.rb'

require 'drb/drb'

$white=RGB(0xff,0xff,0xff)
$red=RGB(0xff,0,0)
$blue=RGB(0,0,0xff)
$green=RGB(0,0xff,0)
$black=RGB(0,0,0)

class MyDrawingCanvasPanel < VRCanvasPanel
  include VRMouseFeasible
  def vrinit
    super
  end
  def set_font(fontname, fsize)
    rFactory = SWin::LWFactory.new SWin::Application.hInstance
    vrfont = rFactory.newfont(fontname, fsize)
    self.canvas.setFont(vrfont)
  end
  def clear
    self.createCanvas 800,800
  end
  def easyrefresh
    dopaint{
      self_paint
    }
  end
end
=begin
class Wrapper
  def initialize(canvas)
    @canvas = canvas
  end
  def cv
    @canvas
  end
    
end
=end
class MyForm < VRForm
#  include VRresizeSensitive
#  include VRMenuUsable
  def construct
    self.caption="canvas test"
    addControl(MyDrawingCanvasPanel,"cv","canvas",0,0,800,800)
    addControl(VRButton,  "btn1","Refresh",0,801,100,50)
    addControl(VRButton,  "btn2","Exit",101,801,100,50)
    addControl(VRButton,  "btn3","Clear",201,801,100,50)

    @cv.createCanvas 800,800

    DRb.start_service('druby://localhost:3010', @cv)
    puts DRb.uri
    p @cv.inspect
  end
  def btn1_clicked
    @cv.refresh(false)
  end
  def btn2_clicked
    exit
  end
  def btn3_clicked
    @cv.clear
    @cv.refresh(false)
  end
end

VRLocalScreen.start(MyForm, 300, 300, 800, 1000)
=begin
module MyForm
  def construct
    self.caption="canvas test"
    addControl(MyDrawingCanvasPanel,"cv","canvas",0,0,800,800)
    addControl(VRButton,  "btn1","ボタンだよ",0,801,190,900)
    addControl(VRButton,  "btn2","ボタンだよ",200,801,390,900)
    addControl(VRButton,  "btn3","ボタンだよ",400,801,590,900)
    addControl(VRButton,  "btn4","ボタンだよ",600,801,790,900)
    @cv.createCanvas 800,800
#    @cv.draw
#    DRb.start_service('druby://localhost:3010', Wrapper.new(@cv))
    DRb.start_service('druby://localhost:3010', @cv)
    puts DRb.uri
    p @cv.inspect
  end
  def btn1_clicked
    messageBox @btn1.caption,"MSGBOX",0
  end
end

VRLocalScreen.showForm(MyForm)
VRLocalScreen.messageloop
=end

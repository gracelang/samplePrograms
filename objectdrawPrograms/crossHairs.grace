dialect "objectdraw"
print(1@2)
def crossHairs = object {
  inherits graphicApplicationSize(400@400)

  // lines forming crosshairs
  def vertical = lineFrom ((canvas.width/2) @ 0) 
                                      to ((canvas.width/2) @ (canvas.height)) on (canvas)
  def horizontal =
        lineFrom(0 @ (canvas.height/2)) to ((canvas.width) @ (canvas.height/2)) on (canvas)

  // Move the lines to follow the mouse
  method onMouseDrag(point) {

     vertical.setEndPoints((point.x) @ 0,
                       (point.x) @ (canvas.height))
     horizontal.setEndPoints(0 @ (point.y),
                            (canvas.width) @ (point.y))
  }

  def shapes: Choice = menuWithOptions ["FramedSquare","FramedCircle"]

  // required to pop up window and start graphics
  startGraphics
}

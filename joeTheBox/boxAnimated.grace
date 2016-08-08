dialect "objectdraw"
import "box" as box
import "animation" as animation
inherits graphicApplication.size(500, 600)
def boundary = filledRect.at(0@0) size (500, 600) on (canvas)
boundary.color := neutral
boundary.addToCanvas(canvas)
startGraphics

def joe = box.named "Joe"

joe.showOn(canvas)
joe.moveTo(100@50)

method onMousePress(pt:Point) -> Done {
    print "mouse pressed at {pt}"
    joe.moveTo(pt)
}

animation.while {true} pausing 100 do {
    joe.moveBy(5@10)
}

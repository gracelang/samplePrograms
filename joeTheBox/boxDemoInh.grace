dialect "objectdraw"
import "box" as box
inherit graphicApplicationSize(500@600)
def boundary = filledRectAt(0@0) size (500@600) on (canvas)
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

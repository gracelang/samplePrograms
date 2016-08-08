import "box" as box
import "objectdraw" as od

def app = od.graphicApplicationSize (500@500)
app.startGraphics

def joe = box.named "Joe"
joe.showOn(app.canvas)

app.onMousePressDo { event ->
    print "mouse pressed at {event.at}"
    joe.moveTo(event.at)
}

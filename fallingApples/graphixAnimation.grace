import "graphix" as g

// Create the graphics stage
var graphics := g.create(200,400)

def trunk = graphics.addRectangle.at(110@75).setSize(40@325).colored "SaddleBrown".filled(true).draw
def leaves = graphics.addEllipse.at(5@30).setSize(250@140).colored "DarkGreen".filled(true).draw
def apple = graphics.addCircle.at(50@70).setRadius 10 .colored "YellowGreen".filled(true).draw

var applePath

leaves.onMouseDownDo { print "mouse down" ; "error".wombat }
leaves.onMouseUpDo { print "mouse up" ; "error".wombat  }
// leaves.onMouseOverDo { print "mouse over"; "error".wombat  }

apple.onClick := { 
        applePath := fallPath
        graphics.tickEvent(fall, 20)
}
method fallPath {
    def duration = 500
    def path = list [ ]
    def gravity = 0@2
    def damping = 0.5
    var initial := apple.location
    def ground = initial.x@390
    var tick := 0
    var p := initial
    while { p.y < ground.y } do {
        // the fall from rest to the ground
        // uses s = ut + (a.t^2)/2
        tick := tick + 1
        p := initial + (gravity * tick * tick / 2)
        path.addLast(p)
    }
    var v := gravity * tick
    repeat 5 times {
        def u = (0@0) - (v * damping)
        v := u
        tick := 0
        do {
            // the bounce:  
            // uses s = ut + (a.t^2)/2 and v = u + at
            tick := tick + 1
            p := ground + (u * tick) + (gravity * tick * tick / 2)
            v := u + (gravity * tick)
            path.addLast(p)
        } while { p.y < ground.y }
    }
    path
}


def fall = {
    if (applePath.isEmpty) then { 
        graphics.clearTicker
    }
    apple.location := applePath.first
    apple.draw
    applePath.removeFirst
}
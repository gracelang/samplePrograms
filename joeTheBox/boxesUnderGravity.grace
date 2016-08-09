dialect "objectdraw"
import "noahBox" as box
import "animation" as anim
inherits graphicApplicationSize(1000@1000)

// Noah Zentzis
// CS 420 (Object Oriented Programming)
// HW 1 - Dancing Boxes
// April 5, 2016

def boundary = filledRectAt(0@0) size (1000@1000) on (canvas)
boundary.color := color.neutral
boundary.addToCanvas(canvas)

startGraphics

def alice = box.named "A"
alice.showOn(canvas)
alice.moveTo(450@450)

def bob = box.named "B"
bob.showOn(canvas)
bob.moveTo(550@550)

def nullForce = object {
    method calculate(state, time) { 0@0 }
}

var mouseForce := nullForce

class gravity.towards(positionBlock) and(other) {
    def posBlock = positionBlock
    def last = other
    
    method calculate(state, time) {
        // F_g = 0.5 * (G * m1 * m2) / (d ^ 2)
        // not using real gravity, because this is more interesting
        def pos = posBlock.apply
        def dist = state.position.distanceTo(pos)
        def multiplier = 0.5 * 20000 / (dist)
        def vector = (pos) - state.position
        def unit = vector / vector.length
        
        (unit * multiplier) + last.apply.calculate(state, time)
    }
}

method onMousePress(pt:Point) -> Done {
    mouseForce := gravity.towards { pt } and {nullForce}
}

method onMouseDrag(pt:Point) -> Done {
    mouseForce := gravity.towards { pt } and {nullForce}
}

method onMouseRelease(pt:Point) -> Done {
    mouseForce := nullForce
}

def bobForce = gravity.towards {alice.position} and {mouseForce}
def aliceForce = gravity.towards {bob.position} and {mouseForce}

anim.while {true} pausing 10 do {
    alice.moveFor(0.01) accelerating(aliceForce)
    bob.moveFor(0.01) accelerating(bobForce)
    
    if(alice.isOutsideBounds(1000@1000)) then {
        alice.repositionInside(1000@1000)
    }
    if(bob.isOutsideBounds(1000@1000)) then {
        bob.repositionInside(1000@1000)
    }
}

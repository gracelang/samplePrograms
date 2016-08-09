import "objectdraw" as od
import "random" as rand

// Noah Zentzis
// CS 420 (Object Oriented Programming)
// HW 1 - Dancing Boxes
// April 5, 2016

// State value for RK4 integration
class state.at(pos : Point) withVelocity(vel : Point) {
    var position is readable := pos
    var velocity is readable := vel
    
    method evaluateAt(t) for(dt) withDerivative(d) accelFunc(f) {
        var s := state.at(position + d.d_pos * dt) withVelocity(velocity + d.d_vel * dt)
        
        derivative.withVel(s.velocity) accel(f.calculate(s, t + dt))
    }
    
    method integrateAt(t) for(dt) withAccelerationFunction(func) {
        // Perform one RK4 integration step
        var d_a := derivative.withVel(0@0) accel(0@0)
        
        // Compute partial derivatives
        d_a := self.evaluateAt(t) for(0) withDerivative(d_a) accelFunc(func)
        def d_b = self.evaluateAt(t) for(dt * 0.5) withDerivative(d_a) accelFunc(func)
        def d_c = self.evaluateAt(t) for(dt * 0.5) withDerivative(d_b) accelFunc(func)
        def d_d = self.evaluateAt(t) for(dt) withDerivative(d_c) accelFunc(func)
        
        // Compute final derivatives of position and velocity
        def dxdt = (d_a.d_pos + (d_b.d_pos + d_c.d_pos) * 2 + d_d.d_pos) * (1/6)
        def dvdt = (d_a.d_vel + (d_b.d_vel + d_c.d_vel) * 2 + d_d.d_vel) * (1/6)
        
        // Update state variables
        position := position + dxdt * dt
        velocity := velocity + dvdt * dt
    }
    
    method asString {
        "<state {position} moving at {velocity}>"
    }
    
    method isOutsideBounds(size : Point) {
        (position.x < 0) ||
        (position.y < 0) ||
        (position.x > size.x) ||
        (position.y > size.y)
    }
}

// Derivative value for RK4 integration
class derivative.withVel(vel : Point) accel(accel : Point) {
    def d_pos is readable = vel
    def d_vel is readable = accel
}

method named(name) {
  object {
    var myState is readable := state.at(0@0) withVelocity(0@0)
    var now is readable := 0
    var extent is public := defaultExtent
    
    def noRect = object { 
        inherits Singleton.new
        def asString is readable = "noRect"
        method moveTo { }
        method visible:=(_) { }
    }
    var myRect := noRect
    
    method defaultExtent {
        20@20
    }
    
    method showOn(canvas) {
        if (myRect == noRect) then {
            myRect := od.framedRectAt(myState.position) size(extent) on (canvas)
        }
        myRect.visible := true
    }
    
    method syncPosition {
        if (myRect != noRect) then {
            myRect.moveTo(myState.position)
        }
    }
    
    method hide {
        myRect.visible := false
    }
    
    method moveTo(location:Point) atVel(vel:Point) {
        myState := state.at(location) withVelocity(vel)
        self.syncPosition
    }
    
    method moveTo(pos : Point) { moveTo(pos) atVel(0@0) }
    
    // accel should have a 'calculate' method that returns the acceleration at
    // a given state and time
    method moveFor(dt) accelerating(accel) {
        myState.integrateAt(now) for(dt) withAccelerationFunction(accel)
        now := now + dt
        self.syncPosition
    }
    
    method position { myState.position }
    
    method isOutsideBounds(size : Point) { myState.isOutsideBounds(size) }
    
    method repositionInside(size : Point) {
        def newPos = ( (rand.between(0) and(size.x))@(rand.between(0) and(size.y)))
        self.moveTo(newPos) atVel(myState.velocity)
    }
    
    method asString {
        "a box named {name}"
    }
  }
}

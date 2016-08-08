//
// Steve Willoughby
// Spring 2016
//
import "objectdraw" as od
import "math" as math
method named(name) {
  object {
    var origin is readable := 0@0
    var heading is public := 0
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
    
    method turnBy(degrees) {
        heading := (heading + degrees) %  360 
    }    
    
    method face(degrees) {
        heading := degrees
    }
    method faceEast {
        // Set heading to 0 degrees explicitly
        face(0)
    }
    
    method showOn(canvas) {
        if (myRect == noRect) then {
            myRect := od.framedRectAt(origin) size(extent) on (canvas)
        }
        myRect.visible := true
    }
    
    method hide {
        myRect.visible := false
    }
    
    method moveTo(location:Point) {
        origin := location
        if (myRect ≠ noRect) then {myRect.moveTo(origin)}
    }
    
    method moveBy(increment:Point) {
        moveTo(origin + increment)
    }
    
    method moveDistance(distance:Number) {
        // Move in the current heading some distance
        moveBy(((heading*π/180).cos*distance)@((heading*π/180.0).sin*distance))
    }
    
    method growBy(increment:Point) {
        extent := extent + increment
        myRect.setSize(extent)
    }
    
    method asString {
        "a box named {name}"
    }
  }
}


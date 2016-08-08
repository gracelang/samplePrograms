//
// Steve Willoughby
// Spring 2016
//
dialect "objectdraw"
import "gUnit" as  gUnit
import "box" as box
import "math" as math

class boxTest.forMethod(m) {
    inherits gUnit.testCaseNamed(m)
    
    var aBox
    var anotherBox
    
    method setup {
        super.setup
        aBox := box.named("a") 
    }
    
    method testHeading {
        assert (aBox.heading == 0) description ("aBox heading not 0")
    }
    
    method testChangeHeading {
        aBox.faceEast
        assert (aBox.heading == 0) description ("did not face 0 degrees when told to face East")
        aBox.turnBy(30)
        assert (aBox.heading == 30) description ("did not turn to 30 degrees")
        aBox.turnBy(366)
        assert (aBox.heading == 36) description  ("did not account for 360 degree circles, hheading is {aBox.heading} instead of 36.}")
    }
    
    method  testRealHeading {
        aBox.faceEast
        aBox.turnBy(6.6)
        assert (aBox.heading == 6.6) description ("heading is {aBox.heading}, should be 6.6")
        aBox.turnBy(360)
        assert (math.abs(aBox.heading - 6.6) < 0.01) description ("heading is {aBox.heading}, didn't wrap around")
    }
    
    method testNegativeHeading {
        aBox.faceEast
        aBox.turnBy(-90)
        assert (aBox.heading == 270) description ("Heading of -90 should be 270 but was {aBox.heading}")
    }
    
    method testMoveDistance {
        aBox.faceEast
     //   aBox.moveTo(0@0)
        aBox.turnBy(90)
        aBox.moveDistance(12)
        assert (((aBox.origin.x-0.0)<0.01) && ((aBox.origin.y - 12.0) < 0.01)) description ("Moved north 12 but ended up at {aBox.origin}")
    }
}

gUnit.testSuite.fromTestMethodsIn(boxTest).runAndPrintResults
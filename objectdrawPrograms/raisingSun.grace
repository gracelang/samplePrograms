dialect "objectdraw"

object {
    inherits graphicApplicationSize (200@200)
    
    // Circle representing the sun
    def sun = filledOvalAt (50 @ 20) size (50 @ 50) on (canvas)
    sun.color := color.yellow

    // Display instructions
    textAt (20 @ 20) with ("Drag the mouse up or down") on (canvas)

    // Drag to raise or lower the sun
    method onMouseDrag (mousePosition: Point) -> Done {
        sun.moveTo (50 @ mousePosition.y)
    }

    startGraphics
}

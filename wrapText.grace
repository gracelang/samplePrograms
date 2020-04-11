dialect "beginningStudent"

method wrap (text:String) to (lineLength:Number) → String {
    // returns a string with the same content as text, but containing internal
    // newlines, so that no line exceeds lineLength in length
    
    var result:String := ""
    var current:Number := lineLength
    def textSize = text.size
    var previousBreakLocation:Number := 0
    
    while {current ≤ textSize} do {
        var breakLocation:Number := text.lastIndexOf " " startingAt (current + 1)
        if (breakLocation == previousBreakLocation) then {
            breakLocation := text.indexOf " " startingAt (current + 1) ifAbsent {textSize + 1}
        }
        result := result ++ text.substringFrom (previousBreakLocation + 1) to (breakLocation - 1) ++ "\n"
        previousBreakLocation := breakLocation
        current := breakLocation + lineLength
    }
    if (previousBreakLocation < textSize) then {
        result := result ++ text.substringFrom (previousBreakLocation + 1)
    } else {
        result := result.substringFrom 1 to (result.size - 1)
    }
    return result
}


describe "text wrapping" with {
    specify "short string to 50" by {
        def short = "A short string that needs no wrapping"
        expect (wrap (short) to 50) toBe (short)
    }
    specify "short string to 8" by {
        def short = "A short string that needs no wrapping"
        expect (wrap (short) to 6) toBe ‹A
short
string
that
needs
no
wrapping›
    }
    
    specify "Lorem ipsum" by {
        def lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc suscipit eu elit eget bibendum. Pellentesque vel erat dapibus, accumsan ligula at, sodales leo. Integer accumsan diam consequat nisi euismod varius. Aliquam augue dolor, egestas sit amet elementum ut, viverra in tellus. Phasellus porttitor laoreet felis id lobortis. Nulla egestas id dui at tristique. Quisque maximus, nulla non sagittis sollicitudin, augue lectus faucibus tortor, vitae ultrices lorem elit eu urna. Etiam efficitur bibendum lectus at sagittis. In pharetra commodo mauris, et porta mi tempus et."
        expect (wrap (lorem) to 80) toBe ‹Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc suscipit eu elit
eget bibendum. Pellentesque vel erat dapibus, accumsan ligula at, sodales leo.
Integer accumsan diam consequat nisi euismod varius. Aliquam augue dolor,
egestas sit amet elementum ut, viverra in tellus. Phasellus porttitor laoreet
felis id lobortis. Nulla egestas id dui at tristique. Quisque maximus, nulla non
sagittis sollicitudin, augue lectus faucibus tortor, vitae ultrices lorem elit
eu urna. Etiam efficitur bibendum lectus at sagittis. In pharetra commodo
mauris, et porta mi tempus et.›
    }
    specify "empty string" by {
        def empty = ""
        expect (wrap (empty) to 80) toBe (empty)
    }
    specify "metric text" by {
        def sp = " " ++ ("." * 8)
        def text = "{sp}1{sp}2{sp}3" * 5
        expect (wrap (text) to 30) toBe (‹ ........1 ........2 ........3
........1 ........2 ........3
........1 ........2 ........3
........1 ........2 ........3
........1 ........2 ........3›)
    }
}
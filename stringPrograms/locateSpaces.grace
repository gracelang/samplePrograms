dialect "minitest"

def s1 = "The king was in his counting house,\ncounting out his money"

method locateSpaces(str:String) {
    // return a list of the locations of all of the spaces in str
    def result = list [ ]
    var foundPoint := 0 
    while { true } do {
        foundPoint := str.indexOf " " 
            startingAt(foundPoint + 1) ifAbsent { return result }
        result.addLast(foundPoint)
    }
}

method locateSpacesWithDo(str:String) {
    // return a list of the locations of all of the spaces in str
    def result = list [ ]
    str.keysAndValuesDo { index, ch -> 
        if (ch == " ") then {result.addLast(index)}
    }
    result
}

method locateSpacesInductively(str:String) {
    // return a list of the locations of all of the spaces in str
    def last = str.lastIndexOf " " ifAbsent { return list [ ] }
    def rest = locateSpacesInductively(str.substringFrom(1)to(last-1))
    rest.addLast(last)
}

testSuite {
    test "equivalence" by {
        def arg = "ello ello ello, what's going on here?"
        assert (locateSpaces(arg)) shouldBe
            (locateSpacesInductively(arg))
        assert (locateSpaces(arg)) shouldBe
            (locateSpacesWithDo(arg))
    }
    test "equivalenceNoSpaces" by {
        def arg = "NoSPAcesHere?"
        assert (locateSpaces(arg)) shouldBe
            (locateSpacesInductively(arg))
        assert (locateSpaces(arg)) shouldBe
            (locateSpacesWithDo(arg))
    }
    test "equivalenceEmpty" by {
        def arg = ""
        assert (locateSpaces(arg)) shouldBe
            (locateSpacesInductively(arg))
        assert (locateSpaces(arg)) shouldBe
            (locateSpacesWithDo(arg))
    }
    test "equivalenceAllSpaces" by {
        def arg = "         "
        assert (locateSpaces(arg)) shouldBe
            (locateSpacesInductively(arg))
        assert (locateSpaces(arg)) shouldBe
            (locateSpacesWithDo(arg))
    }
}
dialect "minitest"
import "twoThreeTreeWithDelete" as twoThreeTree
import "random" as random
import "io" as io

testSuiteNamed "basic 2-3 tree" with {
    
    def e = twoThreeTree.empty⟦Number, String⟧

    test "empty size" by {
        assert (e.size) shouldBe 0
    }
    
    test "empty do" by {
        e.do { each -> failBecause "empty 2-3-tree did!" }
        assert (true)
    }
 
    test "add to empty" by {
        e.at 3 put "three"
        var contents := list.empty
        assert (e.size) shouldBe 1
        e.do { each -> contents.add(each) }
        assert (contents) shouldBe [ 3::"three" ]
    }
    
    test "add 3 and 2 to empty size" by {
        e.at 3 put "three".at 2 put "two"
        assert (e.size) shouldBe 2
    }

    test "add 3 and 2 to empty contents" by {
        e.at 3 put "three".at 2 put "two"
        var contents := list.empty
        e.do { each -> contents.add(each) }
        assert (contents) shouldBe [ 2::"two", 3::"three" ]
    }
    
    test "add 3, 2 and 1 to empty size" by {
        e.at 3 put "three".at 2 put "two".at 1 put "one"
        assert (e.size) shouldBe 3
    }

    test "add 3, 2 and 1 to empty contents" by {
        e.at 3 put "three".at 2 put "two".at 1 put "one"
        var contents := list.empty
        e.do { each -> contents.add(each) }
        assert (contents) shouldBe [ 1::"one", 2::"two", 3::"three" ]
    }

    test "add 1–4 to empty size" by {
        e.at 2 put "two".at 3 put "three".at 1 put "one".at 4 put "four"
        assert (e.size) shouldBe 4
    }

    test "add 1–4 to empty contents" by {
        e.at 2 put "two".at 3 put "three".at 1 put "one".at 4 put "four"
        var contents := list.empty
        e.do { each -> contents.add(each) }
        assert (contents) shouldBe [ 1::"one", 2::"two", 3::"three", 4::"four" ]
    }

    test "add 1–5 to empty size" by {
        e.at 2 put "two".at 3 put "three".at 1 put "one".at 4 put "four"
            .at 5 put "five"
        assert (e.size) shouldBe 5
    }

    test "add 1–5 to empty contents" by {
        e.at 2 put "two".at 3 put "three".at 1 put "one".at 4 put "four"
        e.at 5 put "five"
        var contents := list.empty
        e.do { each -> contents.add(each) }
        assert (contents) shouldBe [ 1::"one", 2::"two", 3::"three", 4::"four",
            5::"five" ]
    }

    test "at 1" by {
        e.at 2 put "two".at 3 put "three".at 1 put "one".at 4 put "four"
            .at 5 put "five"
        assert (e.at 1) shouldBe "one"
    }

    test "at 2" by {
        e.at 2 put "two".at 3 put "three".at 1 put "one".at 4 put "four"
            .at 5 put "five"
        assert (e.at 2) shouldBe "two"
    }

    test "at 3" by {
        e.at 2 put "two".at 3 put "three".at 1 put "one".at 4 put "four"
            .at 5 put "five"
        assert (e.at 3) shouldBe "three"
    }

    test "add 100 random" by {
        def num = 100
        def source = list (1..num)
        def t = twoThreeTree.empty
        while {source.isEmpty.not} do {
            def i = (random.between0And1 * (source.size)).floor + 1
            def n = source.at(i)
            source.removeAt(i)
            t.at (n) put (n*3)
        }
        assert (t.size) shouldBe (num)
        var prev := 0
        t.do { each ->
            prev := prev + 1
            assert (each) shouldBe (prev::(prev*3))
        }
        assert (prev) shouldBe (num)
    }

    test "at 100 random" by {
        def num = 100
        def source = list (1..num)
        def t = twoThreeTree.empty
        while {source.isEmpty.not} do {
            def i = (random.between0And1 * (source.size)).floor + 1
            def n = source.at(i)
            source.removeAt(i)
            t.at (n) put (n*3)
        }
        assert (t.size) shouldBe (num)
        (1..num).do { each ->
            assert (t.at(each)) shouldBe (each*3)
        }
    }
    
    test "at 100 random absent" by {
        def num = 100
        def source = list (1..num)
        def t = twoThreeTree.empty
        while {source.isEmpty.not} do {
            def i = (random.between0And1 * (source.size)).floor + 1
            def n = source.at(i)
            source.removeAt(i)
            t.at (n) put (n*3)
        }
        assert (t.size) shouldBe (num)
        (1..num).do { each ->
            assert (t.at(each+0.5) ifAbsent { "absent" } ) shouldBe "absent"
            assert { 
                t.at(each+0.5) ifAbsent { 
                    NoSuchObject.raise "non-integral argument to at(_)"
                } 
            } shouldRaise (NoSuchObject)
        }
    }
    test "add 1–5 to empty remove 3-4 size & pipe" by {
        e.at 2 put "two".at 3 put "three".at 1 put "one".at 4 put "four"
        e.at 5 put "five"
        e.removeKey 3.removeValue "four"
        assert (e.size) shouldBe 3
        assert (e >> set.empty) shouldBe ([1::"one", 2::"two", 5::"five"] >> set)
    }
    test "add 1–5 to empty remove 3-4 do" by {
        e.at 2 put "two".at 3 put "three".at 1 put "one".at 4 put "four"
        e.at 5 put "five"
        e.removeKey 3.removeValue "four"
        var contents := list.empty
        e.do { each -> contents.add(each) }
        assert (contents) shouldBe [ 1::"one", 2::"two", 5::"five" ]
    }
    test "add 1–5 to empty remove 3-4 iterator" by {
        e.at 2 put "two".at 3 put "three".at 1 put "one".at 4 put "four"
        e.at 5 put "five"
        e.removeKey 3.removeValue "four"
        var contents := set.empty
        def iter = e.iterator
        while { iter.hasNext } do { contents.add (iter.next) }
        assert (contents) shouldBe ([ 1::"one", 2::"two", 5::"five" ] >> set)
    }
    
    test "add 100 random remove even" by {
        def num = 100
        def source = list (1..num)
        def t = twoThreeTree.empty
        while {source.isEmpty.not} do {
            def i = (random.between0And1 * (source.size)).floor + 1
            def n = source.at(i)
            source.removeAt(i)
            t.at(n) put (parity(n))
        }
        assert (t.size) shouldBe (num)
        var prev := 0
        t.do { each ->
            prev := prev + 1
            assert (each) shouldBe (prev::parity(prev))
        }
        assert (prev) shouldBe (num)
        
        t.removeValue("even")
        assert (t.size) shouldBe (num/2)
        t.do { each ->
            assert (parity(each.key)) shouldBe ("odd")
        }
    }
    
}
method parity (n) {
    if ((n % 2) == 0) then {
        "even"
    } else {
        "odd"
    }
}

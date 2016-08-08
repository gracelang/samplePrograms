dialect "minitest"

// imutable lists

def empty = object {
    inherit Singleton.new
    method asString { "[]" }    
    method do(action) { }
}

class cons(hd, tl) {
    // construct a new linked list with head hd and tail tl
    def head is public = hd
    def tail is public = tl
    method asString { 
        "{head}->{tail}"
    }
    method do(action) {
        action.apply(head)
        tail.do(action)
    }
}

testSuite {
    test "emptylist asString" by {
        assert (empty.asString) shouldBe "[]"
    }
    
    test "cons empty and 3" by {
        def e3 = cons(3, empty)
        assert (e3.head) shouldBe 3
        assert (e3.tail) shouldBe (empty)
    }
    
    test "cons empty and 3 asString" by {
        def e3 = cons(3, empty)
        assert (e3.asString) shouldBe "3->[]"   
    }
    test "do" by {
        def oneTo5 = cons(1, cons(2, cons(3, cons(4, cons(5, empty)))))
        var s := ""
        oneTo5.do { each ->
            s := s ++ each ++ " "
        }
        assert(s) shouldBe "1 2 3 4 5 "
    }
    test "head of empty" by {
        assert {empty.head} shouldRaise (Exception)
    } Xco
}
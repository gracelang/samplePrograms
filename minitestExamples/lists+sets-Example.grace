dialect "minitest"

testSuite {
    def l = list [1, 3, 5, 2, 4]

    test "list is mutated by add" by {
        l.add 6
        assert (l.size) shouldBe (6)
    }

    test "list unchanged in separate test" by {
        assert (l.size) shouldBe (5)
    }
}

testSuiteNamed "set tests" with {
    def s = set [1, 3, 5, 2, 4]

    test "set is mutated by add" by {
        s.add(6)
        assert (s.size) shouldBe (6)
    }

    test "set does not contain duplicates" by {
        s.add(1)
        s.add(2)
        assert (s.size) shouldBe (5)
    }
}
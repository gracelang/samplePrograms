dialect "minitest"

testSuiteNamed "subset & superset" with {
    def abcf = set [ "a", "b", "c", "f"]
    def abc = set  ["a", "b", "c"]
    def abx = set ["a", "b", "x"]
    test "subset" by {
        assert (abc.isSubset(abcf)) description "abc ⊄ abcf"
        deny (abcf.isSubset(abc)) description "abcf ⊂ abc"
        deny (abx.isSubset(abc)) description "abx ⊂ abc"
        assert(abx.remove "x".isSubset(abc)) description "ab ⊄ abc"
    }
    test "superset" by {
        assert (abcf.isSuperset(abc)) description "abcf ⊅ abc"
        deny (abc.isSuperset(abcf)) description "abc ⊃ abcf"
        deny (abc.isSuperset(abx)) description "abc ⊃ abx"
        assert (abc.isSuperset(abx.remove("x"))) description "abc ⊅ ab"
    }
}

import "gUnit" as gU
import "binaryTree" as tree
import "unicode" as unicode
import "random" as random

def binaryTreeTest = object {
    class forMethod(m) {
        inherit gU.testCaseNamed(m)

        method tournamentTree(grow, lo, hi) {
            if (lo <= hi) then {
                def k = ((lo + hi) / 2).truncated
                def d = unicode.create("a".ord - 1 + k)
                grow.at(k) put (d)
                tournamentTree(grow, lo, k-1)
                tournamentTree(grow, k+1, hi)
            }
        }

        method testTournamentTreeDo {
            def tt = tree.empty
            tournamentTree(tt, 1, 26)
            def l = list.empty
            tt.do { each -> l.add(each) }
            assert (l) shouldBe ((1..26).map {n -> unicode.create("a".ord - 1 + n)})
        }
        
        method testAsStringEmpty {
            assert (tree.empty.asString) shouldBe "dict⟬⟭"
        }
        method testAsStringNonempty {
            assert (tree.withAll [1::"a", 3::"v", 5::"b"].asString)
                shouldBe "dict⟬1::a, 3::v, 5::b⟭"
        }
        method testAsDebugStringNonempty {
            assert (tree.withAll [1::"a", 3::"v", 5::"b"].asDebugString)
                shouldBe "dict⟬1::\"a\", 3::\"v\", 5::\"b\"⟭"
        }
        method testIsEmptyOfEmptyTree {
            assert (tree.empty.isEmpty) shouldBe (true)
        }
        method testIssizeEmptyTree {
            assert (tree.empty.size) shouldBe (0)
        }
        method testIsEmptyOfNonEmptyTree {
            assert (tree.with("a"::1).isEmpty) shouldBe (false)
        }
        method testSizeOfNonEmptyTree {
            assert (tree.with("a"::1).size) shouldBe (1)
        }
        method testSizeAfterRemoval {
            def t = tree.with(1::"a")
            assert (t.removeKey(1)  ifAbsent { failBecause "ifAbsent action executed" }) shouldBe (1::"a")
            assert (t.size) shouldBe (0)
        }
        method testAddToEmptyTree {
            def t = tree.empty
            t.at(1)put(1)
            assert (t.isEmpty) shouldBe (false)
        }
        method testAtWithOneNode {
            def t = tree.with("a"::1)
            assert (t.at("a")) shouldBe (1)
        }
        method testAtWithALeftNode {
            def t = tree.withAll ["b"::1, "a"::2]
            assert (t.at("a")) shouldBe (2)
            assert (t.at("b")) shouldBe (1)
        }
        method testAtWithARightNode {
            def t = tree.withAll ["a"::1, "c"::2]
            assert (t.at("a")) shouldBe (1)
            assert (t.at("c")) shouldBe (2)
        }
        method testRemoveFromEmtpyTree {
            var executed := false
            def t = tree.empty
            t.removeKey(1) ifAbsent { executed := true }
            assert (executed) description "ifAbsent action was not executed"
            assert (t.size) shouldBe 0
        }
        method testRemoveNodeWithNoChildrenFromTree {
            def t = tree.with(1::2)
            def res = t.removeKey(1) ifAbsent { failBecause "ifAbsent action executed" }
            assert (t.isEmpty) shouldBe (true)
            assert (res) shouldBe (1::2)
        }
        method testRemoveNodeWithRightChildFromTree {
            def t = tree << [1::"a", 2::"b"]
            def res = t.removeKey(1) ifAbsent { failBecause "ifAbsent action executed" }
            assert (t.isEmpty) shouldBe (false)
            assert (res) shouldBe(1::"a")
            assert (t.at(2)) shouldBe ("b")
        }
        method testRemoveNodeWithLeftChildFromTree {
            def t = tree.withAll [2::"b", 1::"a"]
            def res = t.removeKey(2) ifAbsent { failBecause "ifAbsent action executed" }
            assert (t.isEmpty) shouldBe (false)
            assert (t.at(1)) shouldBe ("a")
            assert (res) shouldBe (2::"b")
        }
        method testRemoveNodeWithBothChildrenFromTree {
            def t = tree.withAll [2::"b", 1::"a", 3::"c"]
            def res = t.removeKey(2) ifAbsent { failBecause "ifAbsent action executed" }
            assert (t.isEmpty) shouldBe (false)
            assert (res) shouldBe (2::"b")
            assert (t.at(1)) shouldBe ("a")
            assert (t.at(3)) shouldBe ("c")
        }
        method testRemoveInnerNodeFromTree {
            def t = tree.withAll [4::"d", 2::"b", 1::"a", 3::"c"]
            def res = t.removeKey(2) ifAbsent { failBecause "ifAbsent action executed" }
            assert (t.isEmpty) shouldBe (false)
            assert (res) shouldBe(2::"b")
            assert (t.at(1)) shouldBe ("a")
            assert (t.at(3)) shouldBe ("c")
            assert (t.at(4)) shouldBe ("d")
        }
        method testIteratorTT {
            def tt = tree.empty
            tournamentTree(tt, 1, 26)
            def ks = list.empty
            def vs = list.empty
            def iter = tt.iterator
            while { iter.hasNext } do { 
                def each = iter.next
                ks.add(each.key)
                vs.add(each.value)
            }
            assert (ks) shouldBe ((1..26))
            assert (vs) shouldBe ((1..26).map {n -> unicode.create("a".ord - 1 + n)})
        }
        method testRandomRemovesAndReinsertions {
            def tt = tree.empty
            def maxKey = 50
            tournamentTree(tt, 1, maxKey)
            def orig = tt.copy
            (1..100).do { n ->
                def randKey = random.integerIn 1 to (maxKey)
                def val = tt.at(randKey)
                def res = tt.removeKey(randKey) ifAbsent {
                    failBecause "key {randKey} not present in {tt} on remove {n}"
                }
                assert (tt.size) shouldBe (maxKey - 1)
                assert (res) shouldBe (randKey::val)
                tt.at(randKey) put (val)
                assert (tt.size) shouldBe (maxKey)
                assert (tt) shouldBe (orig)
            }
        }
        
        method testEqualityEmpty {
            assert (tree.empty) shouldBe (tree.empty)
        }
        
        method testEqualityUnit {
            assert (tree.with(1::"a")) shouldBe (tree.with(1::"a"))
        }
        
        method testEqualityTwosome {
            assert (tree.withAll [1::"a", 3::"c"]) 
                  shouldBe (tree.withAll [3::"c", 1::"a"])
        }

        method testIterator {
            def t = tree.withAll [4::"d", 2::"b", 1::"a", 3::"c"]
            def r = list.empty
            def iter = t.iterator
            while {iter.hasNext} do {
                r.addLast(iter.next)
            }
            def desired = list.withAll [1::"a", 2::"b", 3::"c", 4::"d"]
            assert (r) shouldBe (desired)
        }
        method testConcurrentModification {
            def t = tree.withAll [4::"d", 2::"b", 1::"a", 3::"c"]
            def r = list.empty
            def iter = t.iterator
            assert {
                while {iter.hasNext} do {
                    def n = iter.next
                    r.addLast(n)
                    t.at(n.key + 10) put(n.value)
                }
            } shouldRaise (tree.ConcurrentModification)
        }
    }
}

gU.testSuite.fromTestMethodsIn(binaryTreeTest).runAndPrintResults


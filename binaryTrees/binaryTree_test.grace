import "gUnit" as gU
import "binaryTree" as tree
import "unicode" as u

def binaryTreeTest = object {
    class forMethod(m) {
        inherits gU.testCaseNamed(m)

        method tournamentTree(grow, lo, hi) {
            if (lo <= hi) then {
                def k = ((lo + hi) / 2).truncated
                def d = u.create("a".ord - 1 + k)
                grow.at(k) put (d)
                tournamentTree(grow, lo, k-1)
                tournamentTree(grow, k+1, hi)
            }
        }

        method testTournamentTreeDo {
            def tt = tree.empty
            tournamentTree(tt, 1, 26)
            def l = list []
            tt.do { each -> l.add(each.value) }
            assert (l) shouldBe ((1..26).map {n -> u.create("a".ord - 1 + n)})
        }

        method testIsEmptyOfEmptyTree {
            assert (tree.empty.isEmpty) shouldBe (true)
        }
        method testIssizeEmptyTree {
            assert (tree.empty.size) shouldBe (0)
        }
        method testIsEmptyOfNonEmptyTree {
            assert (tree.withAll ["a"::1].isEmpty) shouldBe (false)
        }
        method testSizeOfNonEmptyTree {
            assert (tree.withAll ["a"::1].size) shouldBe (1)
        }
        method testSizeAfterRemoval {
            def t = tree.withAll [1::"a"]
            assert (t.remove(1)) shouldBe (1::"a")
            assert (t.size) shouldBe (0)
        }
        method testAddToEmptyTree {
            def t = tree.empty
            t.at(1)put(1)
            assert (t.isEmpty) shouldBe (false)
        }
        method testAtWithOneNode {
            def t = tree.withAll ["a"::1]
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
            def t = tree.empty
            assert { t.remove(1) } shouldRaise (NoSuchObject)
        }
        method testRemoveNodeWithNoChildrenFromTree {
            def t = tree.withAll [1::2]
            t.remove(1)
            assert (t.isEmpty) shouldBe (true)
        }
        method testRemoveNodeWithRightChildFromTree {
            def t = tree.withAll [1::"a", 2::"b"]
            t.remove(1)
            assert (t.isEmpty) shouldBe (false)
            assert (t.at(2)) shouldBe ("b")
        }
        method testRemoveNodeWithLeftChildFromTree {
            def t = tree.withAll [2::"b", 1::"a"]
            t.remove(2)
            assert (t.isEmpty) shouldBe (false)
            assert (t.at(1)) shouldBe ("a")
        }
        method testRemoveNodeWithBothChildrenFromTree {
            def t = tree.withAll [2::"b", 1::"a", 3::"c"]
            t.remove(2)
            assert (t.isEmpty) shouldBe (false)
            assert (t.at(1)) shouldBe ("a")
            assert (t.at(3)) shouldBe ("c")
        }
        method testRemoveInnerNodeFromTree {
            def t = tree.withAll [4::"d", 2::"b", 1::"a", 3::"c"]
            t.remove(2)
            assert (t.isEmpty) shouldBe (false)
            assert (t.at(1)) shouldBe ("a")
            assert (t.at(3)) shouldBe ("c")
            assert (t.at(4)) shouldBe ("d")
        }
        method testIteratorTT {
            def tt = tree.empty
            tournamentTree(tt, 1, 26)
            def ks = list []
            def vs = list []
            def iter = tt.iterator
            while { iter.hasNext } do { 
                def each = iter.next
                ks.add(each.key)
                vs.add(each.value)
            }
            assert (ks) shouldBe ((1..26))
            assert (vs) shouldBe ((1..26).map {n -> u.create("a".ord - 1 + n)})
        }
        method testIterator {
            def t = tree.withAll [4::"d", 2::"b", 1::"a", 3::"c"]
            def r = list []
            def iter = t.iterator
            while {iter.hasNext} do {
                r.addLast(iter.next)
            }
            def desired = list [1::"a", 2::"b", 3::"c", 4::"d"]
            assert (r) shouldBe (desired)
        }
        method testConcurrentModification {
            def t = tree.withAll [4::"d", 2::"b", 1::"a", 3::"c"]
            def r = list []
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

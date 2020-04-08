// This module implements a dictionary (key -> value mapping) using
// a kind of balanced tree called a 2-3 tree.  All nodes (except the
// root) contain exactly one or two ⟨key, value⟩ mappings, and two or 
// children three  Adding a new mapping to a twoNode produces a threeNode; 
// adding a new mapping to a threeNode splits it into a pair of twoNodes,
// and creates a new entry in the parent node.


type Node⟦K,V⟧ = Unknown

class empty⟦K,V⟧ {
  
    use collections.collection⟦V⟧
    var root := emptyNode
    var mods := 0
    var size is readable := 0
    
    var deletedCount := 0
    
    def Deleted = Singleton.named("Deleted Item")
    
    class twoNode(l:Node⟦K,V⟧, b:Binding⟦K,V⟧, r:Node⟦K,V⟧) is confidential {
        var contents is readable := b
        var left is public := l
        var right is public := r
        method key { contents.key }
        method value { contents.value }
        method asDebugString {
            "(2: {left.asDebugString}, {contents}, {right.asDebugString})"
        }
        method do (action) -> Done {
            left.do(action)
            if (Deleted != contents.value) then {
                action.apply(contents)
            }
            right.do(action)
        }
        method add (new:Binding) setParent (replaceMeBy) absorb (absorb) {
            if (new.key == contents.key) then {
                contents := new
                return
            }
            if (new.key < contents.key) then {
                left.add (new) setParent { nu -> left := nu } absorb { ex ->
                    def newNode = threeNode(ex.left, ex.contents, ex.right, contents, right)
                    replaceMeBy.apply(newNode)
                }
            } else {
                right.add (new) setParent { nu -> right := nu } absorb { ex ->
                    def newNode = threeNode(left, contents, ex.left, ex.contents, ex.right)
                    replaceMeBy.apply(newNode)
                }
            }
        }
        method at (k) ifAbsent (action) {
            if (k == contents.key) then {
                if (Deleted == contents.value) then {
                    action.apply
                } else {
                    contents.value
                }
            } elseif { k < contents.key } then {
                left.at(k) ifAbsent (action)
            } else {
                right.at(k) ifAbsent (action)
            }
        }
        method removeKey (k) ifAbsent (action) {
            if (k == contents.key) then {
                if (Deleted == contents.value) then {
                    action.apply
                } else {
                    contents := (k::Deleted)
                    size := size - 1
                    deletedCount := deletedCount + 1
                }
            } elseif { k < contents.key } then {
                left.removeKey (k) ifAbsent (action)
            } else {
                right.removeKey (k) ifAbsent (action)
            }
        }
        method removeValue (v) {
            left.removeValue (v)
            right.removeValue (v)
            if (v == contents.value) then {
                contents := (contents.key::Deleted)
                size := size - 1
                deletedCount := deletedCount + 1
            }
        }
        
        
        method buildZipperFor (iterator) {
            iterator.remember(tooth)
            left.buildZipperFor(iterator)
        }

        class tooth {
            method visit (iterator) {
                right.buildZipperFor(iterator)
                contents
            }
        }
    }

    class threeNode(l, lb:Binding⟦K,V⟧, m, rb:Binding⟦K,V⟧, r) is confidential {
        var leftContents := lb
        var rightContents := rb
        var left is readable := l
        var middle is readable := m
        var right is readable := r

        method leftKey { leftContents.key }
        method leftValue { leftContents.value }
        method rightKey { rightContents.key }
        method rightValue { rightContents.value }
        method asDebugString {
            "(3: {left.asDebugString}, L: {leftContents}, {middle.asDebugString}, " ++
                "R: {rightContents}, {right.asDebugString})"
        }
        method do (action) -> Done {
            left.do(action)
            if (Deleted != leftContents.value) then {
                action.apply(leftContents)
            }
            middle.do(action)
            if (Deleted != rightContents.value) then {
                action.apply(rightContents)
            }
            right.do(action)
        }
        method add (new:Binding) setParent (replaceMeBy) absorb (absorb) {
            def newKey = new.key
            if (newKey == leftKey) then {
                leftContents := new
                return
            } elseif {newKey == rightKey} then {
                rightContents := new
                return
            }
            if (newKey < leftKey) then {
                left.add(new) setParent { nu -> left := nu } absorb { ex ->
                    def newRight = twoNode(middle, rightContents, right)
                    def newParent = twoNode(ex, leftContents, newRight)
                    absorb.apply(newParent)
                }
            } elseif {newKey > rightKey} then {
                right.add(new) setParent { nu -> right := nu } absorb { ex ->
                    def newLeft = twoNode(left, leftContents, middle)
                    def newParent = twoNode(newLeft, rightContents, ex)
                    absorb.apply(newParent)
                }
            } else {
                middle.add(new) setParent { nu -> middle := nu } absorb { ex ->
                    def newLeft = twoNode(left, leftContents, ex.left)
                    def newRight = twoNode(ex.right, rightContents, right)
                    ex.left := newLeft
                    ex.right := newRight
                    absorb.apply(ex)
                }
            }
        }
        
        method at (k) ifAbsent (action) {
            if (k == leftContents.key) then {
                if (Deleted == leftContents.value) then {
                    action.apply
                } else {
                    leftContents.value
                }
            } elseif { k < leftContents.key } then {
                left.at(k) ifAbsent (action)
            } elseif { k > rightContents.key } then {
                right.at(k) ifAbsent (action)
            } elseif { k == rightContents.key } then {
                if (Deleted == rightContents.value) then {
                    action.apply
                } else {
                    rightContents.value
                }
            } else {
                middle.at(k) ifAbsent (action)
            }
        }
        method removeKey (k) ifAbsent (action) {
            if (k == leftContents.key) then {
                if (Deleted == leftContents.value) then {
                    action.apply
                } else {
                    leftContents := (k::Deleted)
                    size := size - 1
                    deletedCount := deletedCount + 1
                }
            } elseif { k < leftContents.key } then {
                left.removeKey (k) ifAbsent (action)
            } elseif { k > rightContents.key } then {
                right.removeKey (k) ifAbsent (action)
            } elseif { k == rightContents.key } then {
                if (Deleted == rightContents.value) then {
                    action.apply
                } else {
                    rightContents := (k::Deleted)
                    size := size - 1
                    deletedCount := deletedCount + 1
                }
            } else {
                middle.removeKey (k) ifAbsent (action)
            }
        }
        method removeValue (v) {
            left.removeValue(v) 
            middle.removeValue(v) 
            right.removeValue(v)
            if (v == leftContents.value) then {
                leftContents := (leftContents.key::Deleted)
                size := size - 1
                deletedCount := deletedCount + 1
            }
            if (v == rightContents.value) then {
                rightContents := (rightContents.key::Deleted)
                size := size - 1
                deletedCount := deletedCount + 1
            }
        }
        
        
        method buildZipperFor (iterator) {
            iterator.remember(firstTooth)
            left.buildZipperFor(iterator)
        }

        class firstTooth {
            method visit (iterator) {
                iterator.remember(secondTooth)
                middle.buildZipperFor(iterator)
                return leftContents
            }
        }
        class secondTooth {
            method visit (iterator) {
                right.buildZipperFor(iterator)
                return rightContents
            }
        }
    }

    class twoLeafNode(b:Binding) is confidential {
        var contents is readable := b
        method asDebugString {
            "(2L: {contents})"
        }
        method do (action) -> Done {
            if (Deleted != contents.value) then {
                action.apply(contents)
            }
        }
        method add (new:Binding) setParent (replaceMeBy) absorb (absorb) {
            if (new.key == contents.key) then {
                contents := new
                return
            }
            def newNode =
                if (new.key < contents.key) then {
                    threeLeafNode(new, contents)
                } else {
                    threeLeafNode(contents, new)
                }
            replaceMeBy.apply(newNode)
            size := size + 1
        }
        
        method at (k) ifAbsent (action) {
            if (k == contents.key) then {
                if (Deleted == contents.value) then {
                    action.apply
                } else {
                    contents.value
                }
            } else {
                action.apply
            }
        }
        
        method removeKey (k) ifAbsent (action) {
            if (k == contents.key) then {
                if (Deleted == contents.value) then {
                    action.apply
                } else {
                    contents := (k::Deleted)
                    size := size - 1
                    deletedCount := deletedCount + 1
                }
            } else {
                action.apply
            }
        }
        
        method removeValue (v) {
            if (v == contents.value) then {
                contents := (contents.key::Deleted)
                size := size - 1
                deletedCount := deletedCount + 1
            }
        }
        method buildZipperFor (iterator) {
            iterator.remember(tooth)
        }

        class tooth {
            method visit (iterator) {
                contents
            }
        }
    }
    
    class threeLeafNode(lb:Binding, rb:Binding) is confidential {
        var leftContents := lb
        var rightContents := rb
        method leftKey { leftContents.key }
        method leftValue { leftContents.value }
        method rightKey { rightContents.key }
        method rightValue { rightContents.value }
        method asDebugString {
            "(3L: {leftContents}, {rightContents})"
        }
        method do (action) -> Done {
            if (Deleted != leftContents.value) then {
                action.apply(leftContents)
            }
            if (Deleted != rightContents.value) then {
                action.apply(rightContents)
            }
        }
        method add (new:Binding) setParent (replaceMeBy) absorb (absorb)  {
            if (new.key == leftKey) then {
                leftContents := new
                return
            } elseif {new.key == rightKey} then {
                rightContents := new
                return
            }
            size := size + 1
            sort3(leftContents, rightContents, new) in {
                low, mid, high ->
                    def newLeft = twoLeafNode(low)
                    def newRight = twoLeafNode(high)
                    def tempParent = twoNode(newLeft, mid, newRight)
                    absorb.apply(tempParent)
            }
        }
        
        method at (k) ifAbsent (action) {
            if (k == leftContents.key) then {
                if (Deleted == leftContents.value) then {
                    action.apply
                } else {
                    leftContents.value
                }
            } elseif { k == rightContents.key } then {
                if (Deleted == rightContents.value) then {
                    action.apply
                } else {
                    rightContents.value
                }
            } else {
                action.apply
            }
        }
        
        method removeKey (k) ifAbsent (action) {
          if (k == leftContents.key) then {
              if (Deleted == leftContents.value) then {
                  action.apply
              } else {
                  leftContents := (k::Deleted)
                  size := size - 1
                  deletedCount := deletedCount + 1
              }
          } elseif { k == rightContents.key } then {
              if (Deleted == rightContents.value) then {
                  action.apply
              } else {
                  rightContents := (k::Deleted)
                  size := size - 1
                  deletedCount := deletedCount + 1
              }
          } else {
              action.apply
          }
        }
        method removeValue (v) {
            if (v == leftContents.value) then {
                leftContents := (leftContents.key::Deleted)
                size := size - 1
                deletedCount := deletedCount + 1
            }
            if (v == rightContents.value) then {
                rightContents := (rightContents.key::Deleted)
                size := size - 1
                deletedCount := deletedCount + 1
            }
        }
        method buildZipperFor (iterator) {
            iterator.remember(firstTooth)
        }

        class firstTooth {
            method visit (iterator) {
                iterator.remember(secondTooth)
                return leftContents
            }
        }
        class secondTooth {
            method visit (iterator) {
                return rightContents
            }
        }
        method sort3(a, b, c) in (body:Block) is public {
            // Assume a.key ⟦ b.key; execute body with three arguments
            // x, y, z, being a permutation of a, b and c, such that
            // x.key ⟦ y.key ⟦ z.key
            
            def ak = a.key
            def bk = b.key
            def ck = c.key
            if (ck < ak) then { 
                body.apply (c, a, b)
            } elseif {ck < bk} then {
                body.apply (a, c, b)
            } else { 
                body.apply (a, b, c)
            }
        }
    }
    
    class emptyNode is confidential {
        method add(b:Binding) setParent (replaceMeBy) absorb (absorb) {
            replaceMeBy.apply(twoLeafNode(b))
            size := size + 1
        }
        method removeKey (k) ifAbsent (action) {
            action.apply
        }
        method removeValue (v) {
            //do nothing
        }
        method asDebugString { "(empty)" }
        method do(action) { }
        method at (k) ifAbsent (action) { action.apply }
        method buildZipperFor (iterator) { }
        // no need to define tooth. It's not possible to put an
        // emptyNode on a zipper, since it has no children.
    }

    method asDebugString { root.asDebugString }
    method asString { "a two-three tree of size {size}" }

    method do(action:Block⟦Binding⟦K,V⟧, Done⟧) {
        root.do(action)
    }
    class iterator {
        def zipper = list []
        def initialMods = mods

        root.buildZipperFor(self)

        method remember (aTooth) {
            zipper.addLast(aTooth)
        }
            
        method hasNext { zipper.isEmpty.not }

        method next {
            if (mods != initialMods) then {
                ConcurrentModification.raise "on dictionary"
            }
            if (hasNext.not) then {
                IteratorExhausted.raise "on dictionary"
            }
            def thisTooth = zipper.removeLast
            thisTooth.visit(self)
        }
    }
    method isEmpty { size == 0 }
    method at (key) put (value) {
        mods := mods + 1
        root.add (key::value)
            setParent { nu -> root := nu }
            absorb { tba -> root := tba }
        self
    }
    method at (k) ifAbsent (action) {
        root.at (k) ifAbsent (action)
    }
    method at (k) {
        root.at (k) ifAbsent { NoSuchObject.raise "the 2-3 tree does not contain the key {k}" }
    }
    method removeKey (k) ifAbsent (action) {
        mods := mods + 1
        root.removeKey (k) ifAbsent (action)
        rebuildIfSparse
        self
    }
    method removeValue (v) ifAbsent (action) {
        mods := mods + 1
        var prevSize := size
        root.removeValue (v)
        if (size == prevSize) then {
            action.apply
        }
        rebuildIfSparse
        self
    }
    method removeKey (k) {
        mods := mods + 1
        root.removeKey (k) ifAbsent { }
        rebuildIfSparse
        self
    }
    method removeValue (v) {
        mods := mods + 1
        root.removeValue (v)
        rebuildIfSparse
        self
    }
    method rebuildIfSparse is confidential {
        // rebuilds the tree whenever >75% of its nodes are tombstones
        if (deletedCount > (size*3)) then {
            var oldRoot := root
            root := emptyNode
            size := 0
            deletedCount := 0
            oldRoot.do {each -> root.add (each)
                    setParent { nu -> root := nu }
                    absorb { tba -> root := tba }}
        }
    }
    method clear {
        mods := mods + 1
        root := emptyNode
        size := 0
        deletedCount := 0
    }
}

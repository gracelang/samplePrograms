// Implements a dicitonary using a binary tree data structure.
// This is not "production quality" code; in particular, the tree is
// not kept balanced.

def ConcurrentModification is public = 
      ProgrammingError.refine "ConcurrentModification" 
    // Raised if the tree is modified while being iterated.

method asString { "the binaryTree factory" }

method empty { withAll [] }

method with⟦K,V⟧ (x:Binding⟦K,V⟧) { withAll [x] }

method << (source) { withAll(source) }
    
class withAll⟦K,V⟧ (pairs:Collection⟦Binding⟦K,V⟧⟧) {
    // Creates a new binary tree and initializes it with the key::value 
    // bindings in pairs.
    use equality

    def emptyNode = object {
        inherit singleton "⏚"
        method isEmpty { true }
        method height { 0 }
        method do(action:Procedure1) { }
        method preorderKeysAndValuesDo(action:Procedure2) { }
    }
    
    type Node = interface {
        key -> K
        key:=(k:K) -> Done
        value -> V
        value:=(v:V) -> Done
        left -> MaybeNode
        left:=(n: MaybeNode) -> Done
        right -> MaybeNode
        right:=(n: MaybeNode) -> Done
        height -> Number
        do(Action:Procedure1) -> Done
        preorderKeysAndValuesDo(action:Procedure2) -> Done
        isEmpty -> Boolean
        hash -> Number
    }

    def MaybeNode = Node | emptyNode
    // References in the binary tree may be to other nodes, or to emptyNode

    class nodeContaining(key':K, value':V)
                withChildren(left':MaybeNode, right':MaybeNode) -> Node {
        use identityEquality
        var key is public := key'
        var value is public := value'
        var left is public := left'
        var right is public := right'
        method isEmpty { false }
        method asString { "nd({key}, {value}, {left}, {right})" }
        method asDebugString { 
            "nd({key.asDebugString}, {value.asDebugString}, {left.asDebugString}, {right.asDebugString})"
        }
        method height { 1 + max(left.height, right.height) }
        method do(action:Procedure1) {
            left.do(action)
            action.apply(key::value)
            right.do(action)
        }
        method preorderKeysAndValuesDo(action:Procedure2) {
            action.apply(key, value)
            left.preorderKeysAndValuesDo(action)
            right.preorderKeysAndValuesDo(action)
        }
    }

    
    method nodeContaining(key:K, value:V) -> Node is confidential {
        nodeContaining(key, value) withChildren(emptyNode, emptyNode)
    }

    var root is readable := emptyNode
    var size is readable := 0
    var eventCount := 0
    
    addAll(pairs)
    
    method height { root.height } 

    method at(key) put(value) {
        addNode(nodeContaining(key, value)) in (root) setParent { new ->
            root := new }
        eventCount := eventCount + 1
        self
    }
    
    method asString { 
        var result := "dict⟬"
        var first := true
        bindingsDo { each -> 
            if (first.not) then { 
                result := result ++ ", " 
            } else { 
                first := false 
            }
            result := result ++ each 
        }
        result ++ "⟭"
    }
    
    method asDebugString { 
        var result := "dict⟬"
        var first := true
        bindingsDo { each -> 
            if (first.not) then { 
                result := result ++ ", " 
            } else { 
                first := false 
            }
            result := result ++ each.asDebugString 
        }
        result ++ "⟭"
    }
    
    method addNode(newNode) in (r) setParent (setParentRef) is confidential {
        // Adds newNode to the binary search tree rooted at r.  setParentRef
        // is a block that is used to modify the final step of the path by
        // which this node was reached.
        if (r.isEmpty) then { 
            setParentRef.apply(newNode)
            size := size + 1
        } elseif { newNode.key == r.key } then {
            r.value := newNode.value
        } elseif { newNode.key < r.key } then {
            addNode(newNode) in (r.left) setParent { new -> r.left := new }
        } else {
            addNode(newNode) in (r.right) setParent { new -> r.right := new }
        }
    }

    method addAll(newPairs) {
        newPairs.do { each -> at(each.key) put(each.value) }
    }

    method removeKey(key) {
        // Remove key and its associated value from this tree.
        // It's an error for key not to be present.
        eventCount := eventCount + 1
        removeKey(key) from(root) ifAbsent {
            NoSuchObject.raise "key {key} not present"
        } setParent { val -> root := val } 
    }

    method removeKey(key) ifAbsent (absentAction) {
        // Remove key from this tree, and return the removed key::value binding.
        // If key is not present, apply absentAction and return its result.
        eventCount := eventCount + 1
        removeKey(key) from (root) ifAbsent (absentAction) setParent { val -> root := val }
    }
    
    method removeKey(key) from (r) ifAbsent (absentAction) 
                setParent (setParentReference) is confidential {
        // Remove key from the subtree r.  setParentReference is a block that
        // will assign its argument to a variable of the caller's choosing.
        // Returns key and its associated value as a binding.
        // If key is not present, then absentAction will be applied and its
        // result returned.
        if (r.isEmpty) then { 
                absentAction.apply
        } elseif { key == r.key } then {
            def result = r.key::r.value
            if (r.right.isEmpty) then {
                setParentReference.apply(r.left)
                size := size - 1
            } elseif { r.left.isEmpty } then  {
                setParentReference.apply(r.right)
                size := size - 1
            } else {    // two children
                def leftMax = maxElement(r.left)
                removeKey(leftMax.key) from (r.left) ifAbsent { ... }
                    setParent { val -> r.left := val }
                r.key := leftMax.key
                r.value := leftMax.value
            }
            result
        } elseif { key > r.key } then {
            removeKey(key) from (r.right) ifAbsent (absentAction) 
                setParent { new -> r.right := new }
        } else { // key < r.key
            removeKey(key) from (r.left) ifAbsent (absentAction) 
                setParent { new -> r.left := new }
        }
    }
    
    method maxElement(rootNode) is confidential {
        // return the maximum key::value binding from the subtree
        // rooted at rootNode, which must not be empty.
        var current := rootNode
        while { current.right.isEmpty.not } do {
            current := current.right
        }
        def maxKey = current.key
        def maxVal = current.value
        return maxKey::maxVal
    }
    
    method at(key) {
        at(key) ifAbsent { 
            NoSuchObject.raise "key {key} not present"
        }
    }

    method at(key) ifAbsent (absentAction) {
        def at' = { key', currentNode -> 
            if (currentNode.isEmpty) then { 
                absentAction.apply
            } elseif { key' < currentNode.key } then {
                at'.apply(key', currentNode.left)
            } elseif { key' > currentNode.key } then {
                at'.apply(key', currentNode.right)
            } else {
                return currentNode.value
            }
        }
        at'.apply(key, root)
    }
    method isEmpty { root.isEmpty }
    method copy {
        def newTree = outer.empty
        root.preorderKeysAndValuesDo { k, v ->
            newTree.at(k) put(v)
        }   // we use preorder to create the copy to avoid creating a
            // highly unblanced tree.
        newTree
    }
    method do(action1) {
        root.do{ each:Binding -> action1.apply(each.value) }
    }

    method valuesDo(action1) {
        root.do{ each:Binding -> action1.apply(each.value) }
    }

    method keysDo(action1) {
        root.do{ each:Binding -> action1.apply(each.key) }
    }
    
    method keysAndValuesDo(action1) {
        root.do{ each:Binding -> action1.apply(each.key, each.value) }
    }
    method bindingsDo(action1) {
        root.do(action1)
    }
    
    type MinimalDict = interface {
        size -> Number
        at(k:Object) ifAbsent(action:Procedure1) -> Object
    }
    
    method == (other:MinimalDict) {
        if (size != other.size) then { 
            return false
        }
        keysAndValuesDo { k, v -> 
            if ((other.at(k) ifAbsent { return false }) != v) then {
                return false
            }
        }
        true
    }

    class iterator⟦T⟧ {
        def zipper is readable = list.empty
        def savedEventCount = eventCount
        addLeftmostPath(root)
        method addLeftmostPath(start) is confidential {
            var n := start
            while { n.isEmpty.not } do {
                zipper.addLast(n) 
                n := n.left
            }
        }
        method hasNext { zipper.isEmpty.not }
        method next {
            if (savedEventCount != eventCount) then {
                ConcurrentModification.raise "the tree has changed!"
            }
            if (!hasNext) then {
                IteratorExhausted.raise "on Tree" 
            } 
            def current = zipper.removeLast
            addLeftmostPath(current.right)
            current.key::current.value
        }
    }
}




def ConcurrentModification = ProgrammingError.refine "ConcurrentModification "

method empty {
    withAll []
}

class withAll(pairs:Collection) {
    // answers a new mutable binary tree containing pairs, a which must be
    // a collection of key-value bindings.

    class nodeContaining(key', data')withChildren(left', right') is confidential {
        var key is readable := key'
        var data is public := data'
        var left is public := left'
        var right is public := right'
        method isEmpty { false }
        method asString { "Node({key}, {data}, {left}, {right})" }
        method copy { 
            nodeContaining(key, data) withChildren(left.copy, right.copy)
        }
        method height { 1 + max(left.height, right.height) }
        method do(block1) {
            left.do(block1)
            block1.apply(key::data)
            right.do(block1)
        }
    }

    def emptyTree = object {
        method isEmpty { true }
        method asString { "emptyTree" }
        method copy { emptyTree }
        method height { 0 }
        method do(block1) { }
    }
    
    method nodeContaining(key, data) is confidential {
        nodeContaining(key, data) withChildren(emptyTree, emptyTree)
    }

    var root := emptyTree
    var size is readable := 0
    var eventCount := 0
    
    addAll(pairs)
    
    method height { root.height }   // TODO: should this be confidential?

    method at(key) put(data) {
        addNode(nodeContaining(key, data))
    }

    method addNode(newNode) is confidential {
        eventCount := eventCount + 1
        def addNode' = { newNode', currentNode -> 
            if (newNode'.isEmpty) then {
                currentNode
            } elseif (currentNode.isEmpty) then {
                size := size + 1
                newNode'
            } elseif (newNode'.key < currentNode.key) then {
                currentNode.left := addNode'.apply(newNode', currentNode.left)
                currentNode
            } elseif (newNode'.key > currentNode.key) then {
                currentNode.right := addNode'.apply(newNode', currentNode.right)
                currentNode
            } else {
                currentNode.data := newNode'.data
                currentNode
            }
        }

        root := addNode'.apply(newNode, root)
    }

    method addAll(newPairs) {
        newPairs.do { each -> at(each.key) put(each.value) }
    }

    method remove(key) {
        eventCount := eventCount + 1
        var removedNode := emptyTree
        var rightBranch := emptyTree

        def remove' = { key', parentNode, currentNode -> 
            if (currentNode.isEmpty) then {
                NoSuchObject.raise "Can't remove key {key} because it is not present"
            } elseif (key' < currentNode.key) then {
                currentNode.left := remove'.apply(key', currentNode, currentNode.left)
                currentNode
            } elseif (key' > currentNode.key) then {
                currentNode.right := remove'.apply(key', currentNode, currentNode.right)
                currentNode
            } else {
                size := size - 1
                removedNode := currentNode
                rightBranch := currentNode.right
                currentNode.left
            }
        }

        root := remove'.apply(key, emptyTree, root)
        addNode(rightBranch)
        if (!rightBranch.isEmpty) then { size := size - 1 } 
        removedNode.key::removedNode.data
    }
    method at(key) {
        def at' = { key', currentNode -> 
            if (currentNode.isEmpty) then {
                NoSuchObject.raise
            } elseif (key' < currentNode.key) then {
                at'.apply(key', currentNode.left)
            } elseif (key' > currentNode.key) then {
                at'.apply(key', currentNode.right)
            } else {
                return currentNode.data
            }
        }
        at'.apply(key, root)
    }
    method isEmpty { root.isEmpty }
    method asString { root.asString }
    method copy {
        def newTree = outer.with
        newTree.addNode(root.copy) 
        newTree
    }
    method do(block1) {
        root.do(block1)
    }
    class iterator<T> {
        def zipper is readable = list []
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
            current.key::current.data
        }
    }
}



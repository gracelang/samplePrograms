import "twoThreeTree" as ttt
import "collections" as collections

def NotImplementedError = Exception.refine "not implemented"

type MinimalDictionary = interface {
    size -> Number
    at(_)ifAbsent(_) -> Unknown
}

class treeDictionary⟦K,T⟧ (someItems) {
    use equality
    use collections.collection⟦T⟧
    def theTree = ttt.empty

    someItems.do { item -> theTree.at (item.key) put (item.value) }

    method sizeIfUnknown(action) -> Number { theTree.size }
    method size -> Number { theTree.size }
    method isEmpty { size == 0 }

    method << (source:Collection⟦Binding⟦K,T⟧⟧) { self.addAll(source) }
    method >> (target) { target << self.bindings  }
    
    method containsKey (k:K) -> Boolean {
        theTree.at (k) ifAbsent {return false}
        return true
    }

    method do (action:Procedure1⟦T⟧) -> Done {
        theTree.do { eachBinding -> action.apply(eachBinding.value) }
    }

    method bindingsDo (action:Procedure1⟦Binding⟦K,T⟧⟧) -> Done {
        theTree.do(action)
    }

    method containsValue (v:T) -> Boolean {
        contains (v)
    }

    method contains (v:T) -> Boolean {
        valuesDo { each -> if (each == v) then { return true } }
        false
    }

    // These are out of scope of the assignment to define
    // TODO come back here later if I have time and try to implement them

    method removeAllKeys (keyList) {
        NotImplementedError.raise "removeAllKeys is not implemented yet"
    }
    method removeKey (key) {
        NotImplementedError.raise "removeKey is not implemented yet"
    }
    method removeAllValues (valList) {
        NotImplementedError.raise "removeAllValues is not implemented yet"
    }
    method removeValue (v) {
        NotImplementedError.raise "removeValue is not implemented yet"
    }

    method keys {
        collections.lazySequenceOver (theTree) mappedBy { b -> b.key }
    }

    method values {
        collections.lazySequenceOver (theTree) mappedBy { b -> b.value }
    }

    method bindings {
        collections.lazySequenceOver (theTree) mappedBy { b -> b }
    }

    method keysAndValuesDo (action) {
        bindingsDo { item -> action.apply(item.key, item.value) }
    }

    method keysDo (action) {
        bindingsDo { item -> action.apply(item.key) }
    }

    method valuesDo (action) {
        bindingsDo { item -> action.apply(item.value) }
    }

    method copy {
        treeDictionary(self.bindings)
    }

    method asDictionary {
        dictionary(self.bindings)
    }

    method ++ (other) {
        var d := treeDictionary(self.bindings)
        other.bindingsDo { item -> d.at(item.key)put(item.value) }
        d
    }

    method -- (other) {
        // since we don't have deletions implemented, we need to do a kind of filter
        var d := treeDictionary []
        keysAndValuesDo { k, v ->
            if (!other.containsKey(k)) then {
                d.at (k) put (v)
            }
        }
        d
    }

    method asString {
        var s := "dict⟬"
        var firstElement := true

        bindingsDo { item ->
            if (!firstElement) then {
                s := s ++ ", "
            }
            firstElement := false
            s := s ++ "{item.key}::{item.value}"
        }
        s ++ "⟭"
    }

    method asDebugString {
        "dictionary {theTree.asDebugString}"
    }

    method == (other) {
        if (isMe(other)) then { return true }
        if (MinimalDictionary.matches(other).not) then {
            return false
        }
        if (size != other.size) then { return false }
        keysAndValuesDo { k, v ->
            def otherV = other.at (k) ifAbsent { return false }
            if (v != otherV) then { return false }
        }
        return true
    }

    method at(key) ifAbsent (action) {
        theTree.at (key) ifAbsent (action)
    }
    
    method at (k) {
        at (k) ifAbsent {
            NoSuchObject.raise "dictionary does not contain  key {k}"
        }
    }

    method at (key) put (value) {
        theTree.at (key) put (value)
        self
    }

    method first {
        def it = self.iterator
        if (it.hasNext) then { 
            it.next
        } else {
            BoundsError.raise "no first element in {self}"
        }
    }

    method bindingsIterator { theTree.iterator }

    class iterator {
        // iterating over the tree yields bindings; we want values
        def treeIterator = theTree.iterator
        method hasNext { treeIterator.hasNext }
        method next { treeIterator.next.value }
    }

    class keysIterator {
        def treeIterator = theTree.iterator
        method hasNext { treeIterator.hasNext }
        method next { treeIterator.next.key }
    }

    method do(block1) separatedBy(block0) {
        var firstTime := true
        var i := 0
        self.do { each ->
            if (firstTime) then {
                firstTime := false
            } else {
                block0.apply
            }
            block1.apply(each)
        }
        return self
    }
    method fold(blk)startingWith(initial) {
        var result := initial
        do {it ->
            result := blk.apply(result, it)
        }
        return result
    }
    method map⟦R⟧(block1:Function1⟦T,R⟧) -> Enumerable⟦R⟧ {
        collections.lazySequenceOver(self) mappedBy(block1)
    }
    method filter(selectionCondition:Function1⟦T,Boolean⟧) -> Enumerable⟦T⟧ {
        collections.lazySequenceOver(self) filteredBy(selectionCondition)
    }
    method clear {
        theTree.clear
    }
}

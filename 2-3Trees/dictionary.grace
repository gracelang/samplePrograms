import "twoThreeTree" as ttt

def NotImplementedError = Exception.refine "not implemented"

type MinimalDictionary = type {
    size -> Number
    at(_)ifAbsent(_) -> Unknown
}

// *********** copied from collectionPrelude ****************

type MinimallyIterable⟦T⟧ = type {
    iterator -> Iterator⟦T⟧
}
class lazySequenceOver⟦T,R⟧ (source: MinimallyIterable⟦T⟧) -> Enumerable⟦R⟧ is confidential {
    use collections.enumerable⟦T⟧
    method iterator { source.iterator }
    method size { source.size }
    method isEmpty { source.isEmpty }
    method asDebugString { "a lazy sequence over {source}" }
}
class lazySequenceOver⟦T,R⟧ (source: MinimallyIterable⟦T⟧)
        mappedBy (function:Block1⟦T,R⟧) -> Enumerable⟦R⟧ is confidential {
    use collections.enumerable⟦T⟧
    class iterator {
        def sourceIterator = source.iterator
        method asString { "an iterator over a lazy map sequence" }
        method hasNext { sourceIterator.hasNext }
        method next { function.apply(sourceIterator.next) }
    }
    method size { source.size }
    method isEmpty { source.isEmpty }
    method asDebugString { "a lazy sequence mapping over {source}" }
}

class lazySequenceOver⟦T⟧ (source: MinimallyIterable⟦T⟧)
        filteredBy(predicate:Block1⟦T,Boolean⟧) -> Enumerable⟦T⟧ is confidential {
    use collections.enumerable⟦T⟧
    class iterator {
        var cache
        var cacheLoaded := false
        def sourceIterator = source.iterator
        method asString { "an iterator over filtered {source}" }
        method hasNext {
        // To determine if this iterator has a next element, we have to find
        // an acceptable element; this is then cached, for the use of next
            if (cacheLoaded) then { return true }
            try {
                cache := nextAcceptableElement
                cacheLoaded := true
            } catch { ex:IteratorExhausted -> return false }
            return true
        }
        method next {
            if (cacheLoaded.not) then { cache := nextAcceptableElement }
            cacheLoaded := false
            return cache
        }
        method nextAcceptableElement is confidential {
        // return the next element of the underlying iterator satisfying
        // predicate; if there is none, raises IteratorExhausted.
            while { true } do {
                def outerNext = sourceIterator.next
                def acceptable = predicate.apply(outerNext)
                if (acceptable) then { return outerNext }
            }
        }
    }
    method asDebugString { "a lazy sequence filtering {source}" }
}

class treeDictionary⟦K,T⟧ (someItems) {
    def theTree = ttt.empty

    someItems.do { item -> theTree.at (item.key) put (item.value) }

    method sizeIfUnknown(action) -> Number { theTree.size }
    method size -> Number { theTree.size }
    method isEmpty { size == 0 }
    
    method containsKey (k:K) -> Boolean {
        theTree.at (k) ifAbsent {return false}
        return true
    }

    method do (action:Proc⟦T⟧) -> Done {
        theTree.do { eachBinding -> action.apply(eachBinding.value) }
    }

    method bindingsDo (action:Proc⟦Binding⟦K,T⟧⟧) -> Done {
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
        lazySequenceOver (theTree) mappedBy { b -> b.key }
    }

    method values {
        lazySequenceOver (theTree) mappedBy { b -> b.value }
    }

    method bindings {
        lazySequenceOver (theTree)
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
        if (MinimalDictionary.match(other).not) then {
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
    method map⟦R⟧(block1:Block1⟦T,R⟧) -> Enumerable⟦R⟧ {
        lazySequenceOver(self) mappedBy(block1)
    }
    method filter(selectionCondition:Block1⟦T,Boolean⟧) -> Enumerable⟦T⟧ {
        lazySequenceOver(self) filteredBy(selectionCondition)
    }
    method clear {
        theTree.clear
    }
}

import "gUnit" as gU
import "random" as random
import "dictionary" as z

def td = object {
    method dictionary (initialBindings) {
        z.treeDictionary (initialBindings)
    }
}

def dictionaryTest = object {
    class forMethod(m) {
        inherit gU.testCaseNamed(m)

        var oneToFive
        var evens
        var empty

        method setup {
            oneToFive := td.dictionary ["one"::1, "two"::2, "three"::3,
                "four"::4, "five"::5]
            evens := td.dictionary ["two"::2, "four"::4, "six"::6, "eight"::8]
            empty := td.dictionary [ ]
        }
        method testDictionaryTypeCollection {
            assert (oneToFive) hasType (Collection⟦Binding⟦String,Number⟧⟧)
        }
        method testDictionaryTypeDictionary {
            assert (oneToFive) hasType (Dictionary⟦String,Number⟧)
        }
        method testDictionaryTypeNotTypeWithWombat {
            deny (oneToFive) hasType (Dictionary⟦String,Number⟧ & type { wombat })
        }

        method testDictionarySize {
            assert(oneToFive.size) shouldBe 5
            assert(empty.size) shouldBe 0
            assert(evens.size) shouldBe 4
        }

        method testDictionaryEmptyDo {
            empty.do {each -> failBecause "emptySet.do did with {each}"}
            assert (true)   // so that there is always an assert
        }
        
        method testDictionaryEvensDo {
            def values = set [ ]
            evens.do {each -> values.add(each)}
            assert (values) shouldBe (set [2, 4, 6, 8])
        }

        method testSelfEquality {
            assert (evens == evens)
        }

        method testDictionaryEqualityEmpty {
            assert(empty == emptyDictionary)
            deny(empty != emptyDictionary)
        }
        method testDictionaryInequalityEmpty {
            deny(empty == td.dictionary ["one"::1])
                description "empty dictionary equals dictionary with \"one\"::1"
            assert(empty != td.dictionary ["two"::2])
                description "empty dictionary equals dictionary with \"two\"::2"
            deny(empty == 3)
            deny(empty == evens)
        }
        method testDictionaryEqualityOne {
            assert (td.dictionary ["Hello"::10])
                shouldBe (td.dictionary ["Hello"::10])
        }
        method testDictionaryEqualityTwo {
            assert (td.dictionary ["Hello"::10, "World"::99])
                shouldBe (td.dictionary ["World"::99, "Hello"::10])
        }
        method testDictionaryInequalityFive {
            evens.at "ten" put 10
            assert(evens.size == oneToFive.size) description "evens.size should be 5"
            deny(oneToFive == evens)
            assert(oneToFive != evens)
        }
        method testDictionaryEqualityFive {
            assert(oneToFive) shouldBe (td.dictionary [
                "four"::4, "two"::2, "five"::5, "three"::3, "one"::1
            ])
        }
        method testDictionaryAt {
            assert (evens.at "two") shouldBe 2
            assert (evens.at "four") shouldBe 4
            assert (evens.at "six") shouldBe 6
            assert (evens.at "eight") shouldBe 8
        }
        method testDictionaryAtIfAbsent {
            assert (evens.at "one" ifAbsent { 99 }) shouldBe 99
            assert (evens.at "" ifAbsent { 99 }) shouldBe 99
        }
        method testDictionaryKeysAndValuesDo {
            def accum = td.dictionary [ ]
            var n := 1
            oneToFive.keysAndValuesDo { k, v ->
                accum.at(k)put(v)
                assert (accum.size) shouldBe (n)
                n := n + 1
            }
            assert(accum) shouldBe (oneToFive)
        }
        method testDictionaryEmptyBindingsIterator {
            deny (empty.bindings.iterator.hasNext)
                description "the empty bindings iterator has elements"
        }
        method testDictionaryEmptyIterator {
            def ei = empty.iterator
            deny (ei.hasNext)
                description "the empty bindings iterator has elements"
            assert {ei.next} shouldRaise (IteratorExhausted)
        }
        method testDictionaryEvensBindingsIterator {
            def ei = evens.bindings.iterator
            assert (evens.size == 4) description "evens doesn't contain 4 elements!"
            assert (ei.hasNext) description "the evens iterator has no elements"
            def copyDict = td.dictionary [ei.next, ei.next, ei.next, ei.next]
            deny (ei.hasNext) description "the evens iterator has more than 4 elements"
            assert (copyDict) shouldBe (evens)
        }
        method testDictionaryAdd {
            assert (empty.at "nine" put(9))
                shouldBe (td.dictionary ["nine"::9])
            assert (evens.at "ten" put(10).values.into (emptySet))
                shouldBe (set [2, 4, 6, 8, 10])
        }
        method testDictionaryChaining {
            oneToFive.at "eleven" put(11).at "twelve" put(12).at "thirteen" put(13)
            assert (oneToFive.values.into (emptySet)) shouldBe (set [1, 2, 3, 4, 5, 11, 12, 13])
        }

        method testDictionaryFold {
            assert(oneToFive.fold{a, each -> a + each}startingWith(5))shouldBe(20)
            assert(evens.fold{a, each -> a + each}startingWith(0))shouldBe(20)
            assert(empty.fold{a, each -> a + each}startingWith(17))shouldBe(17)
        }

        method testDictionaryDoSeparatedBy {
            var s := ""
            evens := td.dictionary ["six"::6, "eight"::8]
            evens.do { each -> s := s ++ each.asString } separatedBy { s := s ++ ", " }
            assert ((s == "6, 8") || (s == "8, 6"))
                description "{s} should be \"8, 6\" or \"6, 8\""
        }

        method testDictionaryDoSeparatedByEmpty {
            var s := "nothing"
            empty.do { failBecause "do did when list is empty" }
                separatedBy { s := "kilroy" }
            assert (s) shouldBe ("nothing")
        }

        method testDictionaryDoSeparatedBySingleton {
            var s := "nothing"
            set [1].do { each -> assert(each)shouldBe(1) }
                separatedBy { s := "kilroy" }
            assert (s) shouldBe ("nothing")
        }

        method testDictionaryAsStringNonEmpty {
            def twoFour = td.dictionary ["two"::2, "four"::4]
            assert ((twoFour.asString == "dict⟬two::2, four::4⟭") ||
                        (twoFour.asString == "dict⟬four::4, two::2⟭"))
                        description "dictionary with two and four's asString is ‹{twoFour.asString}›"
        }

        method testDictionaryAsStringEmpty {
            assert (empty.asString) shouldBe ("dict⟬⟭")
        }

        method testDictionaryMapEmpty {
            assert (empty.map{x -> x * x}.into (emptySet)) shouldBe (emptySet)
        }

        method testDictionaryMapEvens {
            assert(evens.map{x -> x + 1}.into (emptySet)) shouldBe (set [3, 5, 7, 9])
        }

        method testDictionaryMapEvensInto {
            assert(evens.map{x -> x + 10}.into(set(evens)))
                shouldBe (set [2, 4, 6, 8, 12, 14, 16, 18])
        }

        method testDictionaryFilterNone {
            assert(oneToFive.filter{x -> false}.isEmpty)
        }

        method testDictionaryFilterEmpty {
            assert(empty.filter{x -> (x % 2) == 1}.isEmpty)
        }

        method testDictionaryFilterOdd {
            assert(oneToFive.filter{x -> (x % 2) == 1}.into (emptySet))
                shouldBe (set [1, 3, 5])
        }

        method testDictionaryMapAndFilter {
            assert(oneToFive.map{x -> x + 10}.filter{x -> (x % 2) == 1}.into(emptySet))
                shouldBe (set [11, 13, 15])
        }
        method testDictionaryBindings {
            assert(oneToFive.bindings.into (emptySet)) shouldBe (
                set ["one"::1, "two"::2, "three"::3, "four"::4, "five"::5])
        }
        method testDictionaryKeys {
            assert(oneToFive.keys.into (emptySet)) shouldBe (
                set ["one", "two", "three", "four", "five"] )
        }
        method testDictionaryValues {
            assert(oneToFive.values.into (emptySet)) shouldBe (
                set [1, 2, 3, 4, 5] )
        }

        method testDictionaryCopy {
            def evensCopy = evens.copy
            evens.at "ten" put 10
            assert (evens.size) shouldBe 5
            assert (evensCopy) shouldBe
                (td.dictionary ["two"::2, "four"::4, "six"::6, "eight"::8])
            assert (evens) shouldBe
                (td.dictionary ["two"::2, "four"::4, "six"::6, "eight"::8, "ten"::10])
        }

        method testDictionaryAsDictionary {
            assert(evens.asDictionary) shouldBe (evens)
        }

        method testDictionaryValuesEmpty {
            def vs = empty.values
            assert(vs.isEmpty)
            assert(vs) shouldBe (emptySequence)
        }
        method testDictionaryKeysEmpty {
            assert(empty.keys) shouldBe (emptySequence)
        }
        method testDictionaryValuesSingle {
            assert(td.dictionary ["one"::1].values) shouldBe
                (sequence [1])
        }
        method testDictionaryKeysSingle {
            assert(td.dictionary ["one"::1].keys) shouldBe
                (sequence ["one"])
        }
        method testDictionaryBindingsEvens {
            assert(set (evens.bindings) ) shouldBe
                (set ["two"::2, "four"::4, "six"::6, "eight"::8])
        }
        method testDictionarySortedOnValues {
            assert(evens.bindings.sortedBy{b1, b2 -> b1.value.compare(b2.value)})
                shouldBe (sequence ["two"::2, "four"::4, "six"::6, "eight"::8])
        }
        method testDictionarySortedOnKeys {
            assert(evens.bindings.sortedBy{b1, b2 -> b1.key.compare(b2.key)})
                shouldBe (sequence ["eight"::8, "four"::4, "six"::6, "two"::2])
        }
        method testDictionaryFailFastIteratorValues {
            def input = td.dictionary ["one"::1, "five"::5, "three"::3, "two"::2, "four"::4]
            def iter = input.iterator
            input.at "three" put(100)
            assert {iter.next} shouldRaise (ConcurrentModification)
            def iter2 = input.iterator
            input.at "three"
            assert {iter2.next} shouldntRaise (ConcurrentModification)
            def iter3 = input.iterator
            input.at "three" put 3
            assert {iter3.next} shouldRaise (ConcurrentModification)
        }
        method testDictionaryFailFastIteratorKeys {
            def input = td.dictionary ["one"::1, "five"::5, "three"::3, "two"::2, "four"::4]
            def iter = input.keys.iterator
            input.at "three" put(100)
            assert {iter.next} shouldRaise (ConcurrentModification)
            def iter2 = input.keys.iterator
            input.at "three"
            assert {iter2.next} shouldntRaise (ConcurrentModification)
            def iter3 = input.keys.iterator
            input.at "three" put 3
            assert {iter3.next} shouldRaise (ConcurrentModification)
        }
        method testDictionaryFailFastIteratorBindings {
            def input = td.dictionary ["one"::1, "five"::5, "three"::3, "two"::2, "four"::4]
            def iter = input.bindings.iterator
            input.at "three" put(100)
            assert {iter.next} shouldRaise (ConcurrentModification)
            def iter2 = input.bindings.iterator
            input.at "three"
            assert {iter2.next} shouldntRaise (ConcurrentModification)
            def iter3 = input.bindings.iterator
            input.at "three" put 3
            assert {iter3.next} shouldRaise (ConcurrentModification)
        }
        method testMerge {
            def evensCopy = td.dictionary ["two"::2, "four"::4, "six"::6, "eight"::8]
            def merge = evens ++ td.dictionary ["two"::22, "three"::3]
            def correctMerge = td.dictionary ["two"::22, "three"::3, "four"::4, "six"::6, "eight"::8]
            assert (merge == correctMerge) description "{merge} shouldBe {correctMerge}"
            assert (evens == evensCopy) description "dictionary ++ changed its target"
        }
        method testDifference {
            def difference = evens -- td.dictionary ["two"::22, "three"::3
            ]
            def correctDifference = td.dictionary ["four"::4, "six"::6, "eight"::8]
            assert (difference == correctDifference) description "{difference} shouldBe {correctDifference}"
            assert (evens == td.dictionary ["two"::2, "four"::4, "six"::6, "eight"::8])
                description "dictionary -- changed its target"
        }
        method testIteratorRandom {
            def num = 100
            def source = list (1..num)
            def t = td.dictionary [ ]
            while {source.isEmpty.not} do {
                def i = random.integerIn 1 to (source.size)
                def n = source.at(i)
                source.removeAt(i)
                t.at (n) put (n*3)
            }
            assert (t.size) shouldBe (num)
            def iter = t.bindingsIterator
            var prev := 0
            while {iter.hasNext} do {
                prev := prev + 1
                assert (iter.next) shouldBe (prev::(prev*3))
            }
            assert (prev) shouldBe (num)
        }
    }
}


def dictInteroperabilityTest = object {
    class forMethod(m) {
        inherit gU.testCaseNamed(m)

        var oneToFive
        var evens
        var empty
        var oneToFiveStd
        var evensStd
        var emptyStd

        method setup {
            oneToFive := td.dictionary ["one"::1, "two"::2, "three"::3,
                                                 "four"::4, "five"::5]
            evens := td.dictionary ["two"::2, "four"::4, "six"::6, "eight"::8]
            empty := td.dictionary [ ]
            oneToFiveStd := prelude.dictionary ["one"::1, "two"::2, "three"::3,
                                                 "four"::4, "five"::5]
            evensStd := prelude.dictionary ["two"::2, "four"::4, "six"::6, "eight"::8]
            emptyStd := prelude.emptyDictionary
        }

        method testDictionaryInequalityEmpty {
            deny(empty == prelude.dictionary ["one"::1])
                description "empty dictionary equals dictionary with \"one\"::1"
            assert(empty != prelude.dictionary ["two"::2])
                description "empty dictionary equals dictionary with \"two\"::2"
            deny(empty == evensStd)
        }
        method testDictionaryInequalityFive {
            deny(oneToFive == evensStd)
            assert(oneToFive != evensStd)
        }
        method testDictionaryEqualityOne {
            assert (td.dictionary ["Hello"::10])
                shouldBe (prelude.dictionary ["Hello"::10])
            assert (prelude.dictionary ["Hello"::10])
                shouldBe (td.dictionary ["Hello"::10])
        }
        method testDictionaryEqualityTwo {
            assert (prelude.dictionary ["Hello"::10, "World"::99])
                shouldBe (td.dictionary ["World"::99, "Hello"::10])
            assert (prelude.dictionary ["Hello"::10, "World"::99])
                shouldBe (td.dictionary ["World"::99, "Hello"::10])
        }
        method testDictionaryEqualityFive {
            assert(oneToFive) shouldBe (oneToFiveStd)
        }
        method testDictionaryEvensBindingsIterator {
            def ei = evens.bindings.iterator
            assert (evens.size == 4) description "evens doesn't contain 4 elements!"
            assert (ei.hasNext) description "the evens iterator has no elements"
            def copyDict = prelude.dictionary [ei.next, ei.next, ei.next, ei.next]
            deny (ei.hasNext) description "the evens iterator has more than 4 elements"
            assert (evens) shouldBe (copyDict)
        }
        method testDictionaryAtPut {
            assert (empty.at "nine" put(9))
                shouldBe (prelude.dictionary ["nine"::9])
        }
        method testDictionaryCopy {
            def evensCopy = evens.copy
            evens.at "ten" put 10
            assert (evens.size) shouldBe 5
            assert (evensCopy) shouldBe
                (prelude.dictionary ["two"::2, "four"::4, "six"::6, "eight"::8])
        }
        method testDictionaryAsDictionary {
            assert(evens.asDictionary) shouldBe (evensStd)
        }
    }
}

def dictRemovalTest = object {
    class forMethod(m) {
        inherit gU.testCaseNamed(m)

        var oneToFive
        var evens
        var empty

        method setup {
            oneToFive := td.dictionary ["one"::1, "two"::2, "three"::3,
                                                 "four"::4, "five"::5]
            evens := td.dictionary ["two"::2, "four"::4, "six"::6, "eight"::8]
            empty := td.dictionary [ ]
        }

        method testDictionaryRemoveKeyTwo {
            assert (evens.removeKey "two".values.into (emptySet)) shouldBe (set [4, 6, 8])
            assert (evens.values.into (emptySet)) shouldBe (set [4, 6, 8])
        }
        method testDictionaryRemoveValue4 {
            assert (evens.size == 4) description "evens doesn't contain 4 elements"
            assert (evens.size == 4) description "initial size of evens isn't 4"
            evens.removeValue 4
            assert (evens.size == 3)
                description "after removing 4, 3 elements should remain in evens"
            assert (evens.containsKey "two") description "Can't find key \"two\""
            assert (evens.containsKey "six") description "Can't find key \"six\""
            assert (evens.containsKey "eight") description "Can't find key \"eight\""
            deny (evens.containsKey "four") description "Found key \"four\""
            assert (evens.removeValue 4 ifAbsent { }.values.into (emptySet)) shouldBe (set [2, 6, 8])
            assert (evens.values.into (emptySet)) shouldBe (set [2, 6, 8])
            assert (evens.keys.into (emptySet)) shouldBe (set ["two", "six", "eight"])
        }
        method testDictionaryRemoveMultiple {
            evens.removeValue 4 .removeValue 6 .removeValue 8
            assert (evens) shouldBe (emptyDictionary.at "two" put 2)
        }
        method testDictionaryRemove5 {
            assert {evens.removeKey 5} shouldRaise (NoSuchObject)
        }
        method testDictionaryRemoveKeyFive {
            assert {evens.removeKey "Five"} shouldRaise (NoSuchObject)
        }


        method testDictionarySizeAfterRemove {
            oneToFive.removeKey "one"
            deny(oneToFive.containsKey "one") description "\"one\" still present"
            oneToFive.removeKey "two"
            oneToFive.removeKey "three"
            assert(oneToFive.size) shouldBe 2
        }

        method testDictionaryContentsAfterMultipleRemove {
            oneToFive.removeKey "one" .removeKey "two" .removeKey "three"
            assert(oneToFive.size) shouldBe 2
            deny(oneToFive.containsKey "one") description "\"one\" still present"
            deny(oneToFive.containsKey "two") description "\"two\" still present"
            deny(oneToFive.containsKey "three") description "\"three\" still present"
            assert(oneToFive.containsKey "four")
            assert(oneToFive.containsKey "five")
        }
        method testDictionaryPushAndExpand {
            evens.removeKey "two"
            evens.removeKey "four"
            evens.removeKey "six"
            evens.at "ten" put(10)
            evens.at "twelve" put(12)
            evens.at "fourteen" put(14)
            evens.at "sixteen" put(16)
            evens.at "eighteen" put(18)
            evens.at "twenty" put(20)
            assert (evens.values.into (emptySet))
                shouldBe (set [8, 10, 12, 14, 16, 18, 20])
        }

        method testDictionaryCopy {
            def evensCopy = evens.copy
            evens.removeKey("two")
            evens.removeValue(4)
            assert (evens.size) shouldBe 2
            assert (evensCopy) shouldBe
                (prelude.dictionary ["two"::2, "four"::4, "six"::6, "eight"::8])
        }

    }
}



def dictTests = gU.testSuite.fromTestMethodsIn(dictionaryTest)
// dictTests.doNotRerunErrors
dictTests.runAndPrintResults

def dictInteropTests = gU.testSuite.fromTestMethodsIn(dictInteroperabilityTest)
dictInteropTests.doNotRerunErrors
dictInteropTests.runAndPrintResults


def dictRemovalTests = gU.testSuite.fromTestMethodsIn(dictRemovalTest)
dictRemovalTests.doNotRerunErrors
dictRemovalTests.runAndPrintResults


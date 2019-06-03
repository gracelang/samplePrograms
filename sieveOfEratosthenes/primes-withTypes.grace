var sieve:List⟦Boolean⟧  //  sieve.at(i) represents the primeness of (2*i) + 1
var limit:Number

method initialize(maxPrime:Number) -> Done {
    limit := maxPrime
    sieve := (1..((limit-1)/2).truncated).map { each:Number -> true } >> list 
}
method markNot(n:Number) -> Done {
    // mark the fact that n is not a prime
    if (n.isEven) then { return }
    sieve.at((n-1)/2) put(false)
}
method next(n:Number) -> Number {
    def start = (n-1)/2
    ((start+1)..limit).do { candidate ->
        if (sieve.at(candidate)) then { return (2*candidate) + 1 }
    }
}

method print -> Done {
    sieve.keysAndValuesDo { n, b -> 
        if (b) then { print((2*n) + 1) } 
    }
}

method runSieve -> Done {
    var currentPrime:Number := 3
    var ix:Number
    do {
        ix := currentPrime * 2
        while {ix ≤ limit} do {
            self.markNot(ix)
            ix := ix + currentPrime
        }
        currentPrime := next(currentPrime)
    } while { (currentPrime * currentPrime) ≤ limit }
}

var sieve  //  sieve.at(i) represents the primeness of (2*i) + 1
var limit 

method initialize(maxPrime) {
    limit := maxPrime
    sieve := (1..((limit-1)/2).truncated).map { each -> true }.asList   
}
method markNot(n) {
    // mark the fact that n is not a prime
    sieve.at((n-1)/2) put(false)
}
method next(n) {
    def start = (n-1)/2
    ((start+1)..limit).do { candidate ->
        if (sieve.at(candidate)) then { return (2*candidate) + 1 }
    }
}

method print {
    sieve.keysAndValuesDo { n, b -> 
        if (b) then { prelude.print((2*n) + 1) } 
    }
}

method runSieve {
    var currentPrime := 3
    var ix
    do {
        ix := currentPrime * 2
        while {ix ≤ limit} do {
            self.markNot(ix)
            ix := ix + currentPrime
        }
        currentPrime := self.next(currentPrime)
    } while { (currentPrime * currentPrime) ≤ limit }
}

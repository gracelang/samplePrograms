dialect "minispec"

describe "pattern construction" with {
    specify "star" by {
        expect (pattern "*".asString) toBe "(star Token)"
    }
    specify "* ABC *" by {
        expect (pattern "*ABC*".asString) toBe "(star Token)(ABC Token)(star Token)"
    }
    specify "* ABC * XYZ *" by {
        expect (pattern "*ABC*XYZ*".asString) toBe "(star Token)(ABC Token)(star Token)(XYZ Token)(star Token)"
    }
}
describe "pattern matching behaviour" with {
    specify "star matches anything" by {
        expect (pattern "*".matches "abc") toBe true
    }
    specify "star matches nothing" by {
        expect (pattern "*".matches "") toBe true
    }
    specify "star matches a single character" by {
        expect (pattern "*".matches "3") toBe true
    }
}

class pattern (patternChars:String) {
    // returns a pattern object defined by patternChars
    // In patternChars, * mathces any sequence of zero or more characters, 
    // and any other chracters match themselves.
    
    def matchTokens = list.empty
    var plainChars := ""
    patternChars.do { ch → 
        if (ch == "*") then {
            if (plainChars.isEmpty.not) then { 
                matchTokens.add(plainToken(plainChars))
                plainChars := ""
            }
            matchTokens.add(starToken)
        } else { 
            plainChars := plainChars ++ ch
        }
    }
    
    method matches (aString:String) {
        tokens (matchTokens) matches (aString) segment 1 to (aString.size)
    }
    
    method tokens (toks) matches (aString) segment (start) to (end) is confidential {
        if (toks.first).
    }
    
    method asString { 
        matchTokens.fold { sum, each → sum ++ each.asString } startingWith ""
    }
        
}

class starToken {
    method matches (another) { true }
    method asString { "(star Token)" }
}

class plainToken(tokenChars) {
    method matches (another) { another.startsWith(tokenChars) }
    method asString { "({tokenChars} Token)" }
}


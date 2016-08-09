var v

method isUndefined(block) {
    try {
        block.apply.asString
        return false
    } catch { e:UninitializedVariable →
        return true
    }
}

if (isUndefined{v}) then {
    print "v is undefined"
} else {
    print(v)
}

v := 5

if (isUndefined{v}) then {
    print "v is undefined"
} else {
    print(v)
}

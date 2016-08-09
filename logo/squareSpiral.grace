dialect "logo"

method squareSpiral(count) {
    for (1..count) do { n ->
        forward(n * 2)
        turnRight 90
    }
}
squareSpiral 100

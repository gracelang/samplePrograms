import "graphix" as graphix
import "binaryTree" as tree
import "unicode" as u

class layout(t) {
    // creates an object that lays-out the tree t
    var col := 0
    def locationOf = dictionary [ ]
    method knuthLayout(root, depth) {
        if (root.left.isEmpty.not) then { knuthLayout(root.left, depth + 1) }
        locationOf.at(root) put(col@depth)
        col := col + 1
        if (root.right.isEmpty.not) then { knuthLayout(root.right, depth + 1) }
    }

    method draw(root) {
        if (root.left.isEmpty.not) then {
            drawEdgeFrom(locationOf.at(root)) to (locationOf.at(root.left))
            draw(root.left)
        }
        if (root.right.isEmpty.not) then {
            drawEdgeFrom(locationOf.at(root)) to (locationOf.at(root.right))
            draw(root.right)
        }
        drawNode(locationOf.at(root), root.data)
    }
    knuthLayout(t.root, 0)
    draw(t.root)
}

// Drawing stuff
def g = graphix.create(200, 300)
def scale = 20
def offset = 15@30

method drawNode(location, label) {
    def shape = g.addCircle.setRadius(10).filled(true).colored "yellow".
          at(location * scale + offset).draw
    def labelText = g.addText.setContent(label).setFont "9px Arial".
          at((location * scale) + offset - (2@6)).draw
}

method drawEdgeFrom(s) to (e) {
    g.addLine.setStart((s * scale) + offset).setEnd((e * scale )+ offset).draw
}

// An example tree to demonstrate the algorithm
def exampleTree = tree.withAll [ ]
tournamentTree(exampleTree, 1, 10)
method tournamentTree(grow, lo, hi) {
    if (lo <= hi) then {
        def k = ((lo + hi) / 2).truncated
        def d = u.create("a".ord - 1 + k)
        grow.at(k) put (d)
        tournamentTree(grow, lo, k-1)
        tournamentTree(grow, k+1, hi)
    }
}

layout(exampleTree)

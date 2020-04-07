import "sys" as sys
import "dom" as dom
type Node = type {
    yes -> Node | emptyTree
    no -> Node | emptyTree
    contents -> Unknown
    isQuestion -> Boolean
    question -> Unknown
    animalName -> Unknown
}
method alert(string) {
    dom.window.alert(string)   
}
method prompt(question) {
    def response = dom.window.prompt(question)
    if (dom.noObject == response) then {
        sys.exit(0)   
    }
    response
}

type BinaryTree = Unknown

method printInstructions {
    alert "Think of an animal.  I will ask you yes–no questions to try to figure out what it is."
}

method populateTree {
    def elephant = animal "elephant"
    def mouse = animal "mouse"
    root := question "Does it have a trunk?" yes(elephant) no(mouse)
}

method learn(guess:Node) {
    // guess is the animal node that was wrong.  Ask the user
    // how to distinguish guess.animalName from the aminal that
    // they were thinking of.
    def newAnimal = prompt "I give up.  What animal were you thinking of?"
    def newQuestion = prompt "What yes–no question will distinguish {articleFor(newAnimal)}{newAnimal} from a {guess.animalName}?"
    def oldAnimalNode = animal(guess.animalName)
    def newAnimalNode = animal(newAnimal)
    // re-purpose `guess` (which was an amimal node) into a question node
    guess.contents := newQuestion
    guess.yes := newAnimalNode
    guess.no := oldAnimalNode
}

method playOneRound(top:BinaryTree) {
    // play one round of the animal-guesing game
    var current := top
    while { current.isQuestion } do {
        if ( ask(current.question) ) then {
            current := current.yes
        } else {
            current := current.no
        }
    }
    
    def article = articleFor(current.animalName)
    if (ask "I guess that your animal is {article}{current.animalName}! Am I right?") then {
        alert "See how smart I am!"
    } else {
        learn(current)
    }
}

method articleFor(str) {
    // the indefinite article to preceed str
    if (str.size == 0) then { return "a nothing" }
    if ("aeioAEIO".contains(str.first).not) then { return "a " }
    if (str.substringFrom 1 to 2 == "a ") then { return "" }
    if (str.substringFrom 1 to 3 == "an ") then { return "" }
    return "an "
}

def goodResponses = 
    dictionary ["yes"::true, "no"::false, "y"::true, "n"::false]

method ask(question:String) -> Boolean {
    //io.output.write(question ++ " ")
    var response := prompt(question)
    if (dom.noObject == response) then {
        sys.exit(0)   
    }
    while { ! goodResponses.containsKey(response) } do {
        response := prompt("Please answer yes or no.\n" ++ question)
        //print "response was {response.asDebugString}"
    }
    goodResponses.at(response)
}

def emptyTree = Singleton.named "emptyTree"


method question(q) yes(yesTree) no(noTree) {
    // returns a new node represnting a question
    if ((yesTree == emptyTree) || (noTree == emptyTree)) then {
        ProgrammingError.raise "subtrees of a question {q} can't be null"
    }
    treeNode(q, yesTree, noTree)
}

method animal(name) {
    // returns a new node representing an animal
    treeNode(name, emptyTree, emptyTree)
}

class treeNode(content, y, n) {
    // manufactures a new tree node, which can be used as
    // question (internal) node, or an animal (leaf) node.
    var yes is public := y
    var no is public := n
    var contents is public := content
    method ==(other) { isMe(other) }
    method isQuestion { yes ≠ emptyTree }
    method question {
        if (isQuestion.not) then { 
            ProgrammingError.raise "this is not a question node. contents = {contents}"
        }
        contents
    }

    method animalName {
        if (isQuestion) then {
            ProgrammingError.raise "this is not an animal node. contents = {contents}"
        }
        contents
    }

    method printTree(indent) {
        var indentString := ""
        repeat (indent) times { indentString := indentString ++ "  " }
        print(indentString ++ self.contents)
        if (self.isQuestion) then {
            print (indentString ++ "yes:")
            self.yes.printTree(indent+1)
            print (indentString ++ "no:")
            self.no.printTree(indent+1)
        }
    }
}


var root
printInstructions
populateTree

do { playOneRound(root) }
    while { ask "\nWould you like to play again?" }
    
print "Thanks for teaching me about some animals.\n"
print "Here is the decision tree.\n"
root.printTree 0

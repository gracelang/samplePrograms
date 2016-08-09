import "graphix" as graphix
import "random" as random

var graphics := graphix.create(200,700)

//
// Game class
//
class createAppleGame(numberOfApples)  {
    method isBadGuess(char) -> Boolean{
        // answers true if char has not been guessed before, and is not in the word.
        // NOT IMPLEMENTED 
        true
    }
    method wordSize -> Number {
        // the size of the current word
        // NOT IMPLEMENTED
    }
    method numberOfBadGuesses -> Number { numberOfApples }
    
    //  add more methods as required
}

def display = createDisplayForGame(createAppleGame(6))

//
// GameDisplay class
//
class createDisplayForGame(g) {
    def trunk is public = graphics.addRectangle.at((110@75)).setSize(40@325).colored "SaddleBrown".filled(true).draw
    def leaves is public = graphics.addEllipse.at((5@30)).setSize(250@140).colored "DarkGreen".filled(true).draw
    //  NOT IMPLEMENTED - Create the correct number of apples. 
    //  The starter code creates only one apple.
    def apple1 = createAppleAt(50@70)
    def newGameButton = graphics.addButton.setText "new game" .setSize(75@33).at(10@450).draw
    def inputBox = graphics.addInputBox.setWidth(40).at(80@450).draw
    // NOT IMPLEMENTED - starter code does not create the row of boxes for the letters to fill.
    inputBox.onSubmitDo { apple1.fall }
    newGameButton.onClick := {
        // NOT IMPLEMENTED - should request the game to start over
        apple1.at(50@75)
        apple1.draw
    }
}

//
// wordList object
//
def wordList = object {
    def words = list [
        "Apple", "Apricot", "Avocado", "Banana", "Bilberry", "Blackberry", 
        "Blackcurrant", "Blueberry", "Boysenberry", "Cantaloupe", "Currant", "Cherry", 
        "Cherimoya", "Cloudberry", "Coconut", "Cranberry", "Damson", "Date", 
        "Dragonfruit", "Durian", "Elderberry", "Feijoa", "Fig", "Grapefruit", "Guava", 
        "Huckleberry", "Jackfruit", "Kiwi", "Kumquat", "Lemon", "Lime", "Loquat", 
        "Lychee", "Mango", "Marionberry", "Melon", "Cantaloupe", "Honeydew", 
        "Watermelon", "Mulberry", "Nectarine", "Olive", "Orange", "Clementine", 
        "Mandarine", "Tangerine", "Papaya", "Passionfruit", "Peach", "Pear", 
        "Persimmon", "Physalis", "Plum", "Pineapple", "Pomegranate", "Pomelo", 
        "Mangosteen", "Quince", "Raspberry", "Salmonberry", "Raspberry", 
        "Rambutan", "Redcurrant", "Satsuma", "Starfruit", "Strawberry", "Tamarillo"]

    method atRandom -> String {
      // returns one of the strings from in the list words, chosen at random.
      def index = (random.between0And1 * words.size).truncated + 1
      words.at(index)
    }
} 

//
// Apple class
//
class createAppleAt(position) {
    inherits graphics.addCircle
    self.at(position).setRadius 10.colored "YellowGreen".filled(true).draw
    var applePath
    def fallAction = {
        if (applePath.isEmpty) then {
            graphics.clearTicker
        } else {
            self.location := applePath.first
            self.draw
            applePath.removeFirst
        }
    }
    
    method fall {
        applePath := fallPath
        graphics.tickEvent(fallAction, 20)
    }
    method fallPath is confidential {
        def duration = 500
        def path = list [ ]
        def gravity = 0@2
        def damping = 0.5
        var initial := self.location
        def ground = initial.x@390
        var tick := 0
        var p := initial
        while { p.y < ground.y } do {
            // the fall from rest to the ground
            // uses s = ut + (a.t^2)/2
            tick := tick + 1
            p := initial + (gravity * tick * tick / 2)
            path.addLast(p)
        }
        var v := gravity * tick
        repeat 5 times {
            def u = (0@0) - (v * damping)
            v := u
            tick := 0
            do {
                // the bounce:
                // uses s = ut + (a.t^2)/2 and v = u + at
                tick := tick + 1
                p := ground + (u * tick) + (gravity * tick * tick / 2)
                v := u + (gravity * tick)
                path.addLast(p)
            } while { p.y < ground.y }
        }
        path
    }
}

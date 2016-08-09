import "graphix" as g

def graphics = g.create(200, 200)
def label = graphics.addText.setContent("Pig Latin Converter").at(0@10).draw
def inputBox = graphics.addInputBox.setWidth(180).at(0@30).draw
def encodeButton = graphics.addButton.setText("Encode").at(0@70).colored("lightblue").draw
def decodeButton = graphics.addButton.setText("Decode").at(60@70).colored("lightgreen").draw
def output = graphics.addText.at(0@100).setContent("").draw

encodeButton.onClick := {
    if (inputBox.value.isEmpty.not) then {
        inputBox.value := encodeWord(inputBox.value)
    }
}

decodeButton.onClick := {
    if (inputBox.value.isEmpty.not) then {
        inputBox.value := decodeWord(inputBox.value)
    }
}

def vowels = list ["a", "e", "i", "o", "u"]

method encodeWord(word) {
    if (!vowels.contains(word.at(1).asLower)) then {
        (word.substringFrom (2) size (word.size)) ++ word.at(1) ++ "ay"
    } else {
        word ++ "yay"
    }
}

method decodeWord(word) {
    if (word.endsWith("yay")) then {
        word.substringFrom (1) size (word.size-3)
    } elseif { word.endsWith "ay"} then {
        (word.at(word.size-2)) ++ (word.substringFrom (1) size (word.size-3))
    } else {
        word
    }
}
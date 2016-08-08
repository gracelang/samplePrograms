import "unicode" as u
import "binaryTree" as bt

def t = bt.empty

(1..26).do { each -> 
    def data = u.create("a".ord - 1 + each)
    t.at(each) put(data)
}

for(t) do { each -> print(each) }

print "height of t is {t.height}."

def tt = bt.empty

method tournamentTree(grow, lo, hi) {
    if (lo <= hi) then {
        def k = ((lo + hi) / 2).truncated
        def d = u.create("a".ord - 1 + k)
        grow.at(k) put (d)
        tournamentTree(grow, lo, k-1)
        tournamentTree(grow, k+1, hi)
    }
}

tournamentTree(tt, 1, 26)
for(tt) do { each -> print(each) }
print "height of tt is {tt.height}."


method foo { print "outer" }

class app {
  method barf { foo }
}

class bar {
  inherit app
  method foo { print "bar" }
}

class baz {
  inherit bar
  method barf { foo }   // ambigous: self.foo or outer.foo?
}


app.barf  //prints "outer"
bar.barf  //prints "outer"
baz.barf  //prints "bar" or "outer", depending on the resolution of foo at line 14

import dict
import debug

fun main()
  var x := dict([])
  x := x.set("bree", "meow")
  x := x.insert("sap", "meow")
  x := x.modify("hazzy", "woof")
  x := x.insert("sap", "woof")
  x := x.set("maxi", "woof")
  x := x.remove("maxi")
  
  println(x.get("bree"))
  println(x.get("sap"))
  println(x)

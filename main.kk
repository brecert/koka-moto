import dict
import debug

fun main()
  dict([])
    .set("bree", "meow")
    .set-if-empty("sap", "meow")
    .set-if-exists("hazzy", "woof")
    .set-if-empty("sap", "woof")
    .set("maxi", "woof")
    .remove("maxi")

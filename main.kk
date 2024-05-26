import dict
import debug
import set

fun main()
  dict([])
    .set("bree", "meow")
    .set-if-empty("sap", "meow")
    .set-if-exists("hazzy", "woof")
    .set-if-empty("sap", "woof")
    .set("maxi", "woof")
    .remove("maxi")

fun test-sets()
  with return(_) println("success!")
  fun expect(a, b, ?(==))
    if a != b then throw("error")

  set([1, 2, 3]).set/add-all(set([3, 4, 5])).set/list.expect([1, 2, 3, 4, 5])
  set([1, 2, 3]).set/keep-shared(set([3, 4, 5])).set/list.expect([3])
  set([1, 2, 3]).set/drop-all(set([3, 4, 5])).set/list.expect([1, 2])
  set([1, 2, 3]).set/with-unique(set([3, 4, 5])).set/list.expect([1, 2, 4, 5])


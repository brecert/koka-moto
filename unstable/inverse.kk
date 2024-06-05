import assert

effect fun add(a: int, b: int) : int
effect fun when(test : () -> bool, onThen: () -> (), onElse: () -> (), assertion: () -> bool) : ()

// todo: reads/writes as inverted (flow) effects

fun normal(action)
s  with fun add(a, b) a + b
  with fun when(test, onThen, onElse, assertion)
    if test() then 
      onThen()
      assert-eq(assertion(), True)
    else
      onElse()
      assert-eq(assertion(), False)
  action()

fun invert(action)
  with fun add(a, b) b - a
  with fun when(test, onThen, onElse, assertion)
    if assertion() then 
      onThen()
      assert-eq(test(), True)
    else
      onElse()
      assert-eq(test(), False)
  action()

fun test()
  with normal
  val a = ref(0)
  a
// unfinished

pub value type flow-state<a>
  Continue
  Break(value : a)

pub effect flow-control<a>
  final ctl break(a: a) : ()
  final ctl continue() : ()

pub fun flow(action)
  val state = ref(Continue)
  with return(_) !state
  with handler
    final ctl break(a)
      state := Break(a)
    final ctl continue()
      state := Continue
  action(state)

pub fun loop(onLoop)
  with state <- flow()
  while { (!state).is-continue }
    onLoop()

pub fun test-loop()
  var i := 0
  loop
    i := i + 1
    if i > 10 then
      break(())
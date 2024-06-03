pub import assert

// :^)

pub fun test(action)
  with return(a)
    println("success")
    a
  action()

// small utility to make writing tests nicer
pub fun test/assert-eq(a, b, ?(==), ?show)
  assert/assert-eq(a, b())
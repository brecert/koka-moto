pub fun assert-eq(a: a, b: a, ?eq/(==): ((a, a) -> e bool), ?show: (a) -> e string) : e ()
  assert("`" ++ a.show ++ "` is not equal to `" ++ b.show ++ "`", a == b)
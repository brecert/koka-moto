import dict

pub alias set<a> = dict<a, ()>

pub fun add(s: set<a>, value: a, ?(==): (a, a) -> e bool) : e set<a>
  s.set(value, ())

pub fun set/remove(s: set<a>, value: a, ?(==): (a, a) -> e bool) : e set<a>
  s.dict/remove(value)

pub fun has(s: set<a>, value: a, ?(==): (a, a) -> e bool) : e bool
  s.has-key(value)

// conversions / creations

pub fun dict/set(d: dict<a, ()>) : set<a>
  d

pub fun list/set(l: list<a>) : set<a>
  l.map(fn(a) (a, ())).set

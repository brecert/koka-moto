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

pub fun set/list(s: set<a>) : list<a>
  s.keys

pub fun set/show(s: set<a>, ?show : (a) -> e string) : e string
  "(" ++ s.keys.map(fn(x) x.show).join(", ") ++ ")"


// type changes

/// Merge all values from d2 into d1
/// keyword: union
pub fun set/add-all(s1: set<a>, s2: set<a>, ?(==): (a, a) -> e bool) : e set<a>
  s1.dict/add-all(s2)

/// Remove all values from d1 that are in d2
/// keyword: set difference
pub fun set/drop-all(s1: set<a>, s2: set<a>, ?(==): (a, a) -> e bool) : e set<a>
  s1.dict/drop-all(s2)

/// Keep only the values that are in both d1 and d2
/// keyword: intersection
pub fun set/keep-shared(s1: set<a>, s2: set<a>, ?(==): (a, a) -> e bool) : e set<a>
  s1.dict/keep-shared-keys(s2)

/// Adds/keeps only the values that are not shared between d1 and d2
/// keyword: symmetric difference
pub fun set/with-unique(s1: set<a>, s2: set<a>, ?(==): (a, a) -> e bool) : e set<a>
  s1.dict/with-unique-keys(s2)
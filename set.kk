import dict

pub alias set<a> = list<a>

pub fun update(s: set<a>, value: a, onUpdate: (old: maybe<a>, new: a) -> e maybe<a>, ?(==): (a, a) -> e bool) : e set<a>
  match s
    Cons(v, rst) ->
      if v == value then
        match onUpdate(Just(v), value)
          Just(v') -> Cons(v', rst)
          Nothing -> rst
      else
        Cons(v, rst.update(value, onUpdate))
    Nil ->
      onUpdate(Nothing, value).maybe(Nil, fn(v) Cons(v, Nil))

pub fun add(s: set<a>, value: a, ?(==): (a, a) -> e bool) : e set<a>
  s.update(value) fn(_, v) Just(v)

pub fun remove(s: set<a>, value: a, ?(==): (a, a) -> e bool) : e set<a>
  s.update(value) fn(_, _) Nothing

pub fun has(s: set<a>, value: a, ?(==): (a, a) -> e bool) : e bool
  s.any fn(v) v == value


// # iteration

pub fun walk(d: set<a>, state: s, action: (state: s, value: a) -> e s) : e s
  d.foldl(state) fn(s, v) action(s, v)

pub fun keep-if(d: set<a>, f: (a) -> e bool) : e set<a>
  d.filter(f)

pub fun drop-if(d: set<a>, f: (a) -> e bool) : e set<a>
  d.keep-if fn(a) !f(a)

// # sets

fun order(s1: set<a>, s2: set<a>) : e (smaller: set<a>, larger: set<a>)
  if s1.length <= s2.length then (s1, s2) else (s2, s1)

/// Merge all values from s2 into s1
/// keyword: union
pub fun add-all(s1: set<a>, s2: set<a>, ?(==): (a, a) -> e bool) : e set<a>
  s2.walk(s1) fn(s, v) s.add(v)

/// Remove all values from s1 that are in s2
/// keyword: set difference
pub fun drop-all(s1: set<a>, s2: set<a>, ?(==): (a, a) -> e bool) : e set<a>
  s2.walk(s1) fn(s, v) s.remove(v)

/// Keep only the values that are in both d1 and d2
/// keyword: intersection
pub fun keep-shared(s1: set<a>, s2: set<a>, ?(==): (a, a) -> e bool) : e set<a>
  val (s, l) = order(s2, s1)
  l.keep-if fn(v) s.has(v)

/// Adds/keeps only the values that are not shared between d1 and d2
/// keyword: symmetric difference
pub fun with-unique(s1: set<a>, s2: set<a>, ?(==): (a, a) -> e bool) : e set<a>
  s1.add-all(s2).drop-all(s1.keep-shared(s2))

// conversions / creations

pub fun dict/set(d: dict<a, ()>) : set<a>
  d.keys

pub fun list/set(l: list<a>) : set<a>
  l

pub fun set/list(s: set<a>) : list<a>
  s

pub fun set/show(s: set<a>, ?show : (a) -> e string) : e string
  "(" ++ s.map(fn(x) x.show).join(", ") ++ ")"
import ext

pub alias dict<k, v> = list<(key: k, value: v)>

// creation

pub fun dict(l: list<(k, v)>) :  dict<k, v>
  l

pub fun empty(d: dict<k, v>) : dict<k, v>
  []

// base functions

// this one "primitive" function should handle all use cases
// but may not be used everywhere because of simplicity (of existing methods) or performance.
/// insert or remove a value for the specified key.
pub fun update(d: dict<k, v>, key: k, onModify: (current: v) -> e maybe<v>, onInsert: () -> e maybe<v>, ?(==): (k, k) -> e bool) : e dict<k, v>
  match d
    Cons((k, v), rst) -> 
      if k == key then 
        match onModify(v)
          Just(v') -> Cons((k, v'), rst)
          Nothing  -> rst
      else
        Cons((k, v), rst.update(key, onModify, onInsert))
    Nil ->
      onInsert().maybe(Nil, fn(v) Cons((key, v), Nil))

/// Replace existing key or add one if it does not exist
pub fun set(d: dict<k, v>, key: k, value: v, ?(==): (k, k) -> e bool) : e dict<k, v>
  d.update(key, value.const, value.const)

/// Add only if key is not present in the dict
pub fun set-if-empty(d: dict<k, v>, key: k, value: v, ?(==): (k, k) -> e bool) : e dict<k, v>
  d.update(key, fn(v) Just(v), value.const)

/// Overwrite any existing key with value
pub fun set-if-exists(d: dict<k, v>, key: k, value: v, ?(==): (k, k) -> e bool) : e dict<k, v>
  d.update(key, fn(_) Just(value), Nothing.const) 

pub fun get(d: dict<k, v>, key: k, ?(==): (k, k) -> e bool) : e maybe<v>
  d.find(fn((k, _)) k == key).map(fn((_, v)) v)

pub fun remove(d: dict<k, v>, key: k, ?(==): (k, k) -> e bool) : e dict<k, v>
  // d.update(key, Nothing.const, Nothing.const)
  d.remove fn((k, _)) k == key

// util

pub fun keep-if(d: dict<k, v>, f: (k, v) -> e bool) : e dict<k, v>
  d.filter fn((k, v)) f(k, v)

pub fun drop-if(d: dict<k, v>, f: (k, v) -> e bool) : e dict<k, v>
  d.keep-if fn(k, v) !f(k, v)

// iteration

pub fun walk(d: dict<k, v>, state: s, action: (state: s, key: k, value: v) -> e s) : e s
  d.foldl(state) fn(s, (k, v)) action(s, k, v)

pub fun map(d: dict<k, v>, action: (k, v) -> e (k, v)) : e dict<k, v>
  d.map fn((k, v)) action(k, v)

// # Sets

fun order(d1: dict<k, v>, d2: dict<k, v>) : e (smaller: dict<k, v>, larger: dict<k, v>)
  if d1.length <= d2.length then (d1, d2) else (d2, d1)

/// Merge all values from d2 into d1
/// keyword: union
pub fun add-all(d1: dict<k, v>, d2: dict<k, v>, ?(==): (k, k) -> e bool) : e dict<k, v>
  d2.walk(d1) fn(d, k, v) d.set(k, v)

/// Remove all values from d1 that are in d2
/// keyword: set difference
pub fun drop-all(d1: dict<k, v>, d2: dict<k, v>, ?(==): (k, k) -> e bool) : e dict<k, v>
  d1.drop-if fn(k, _) d2.has-key(k)

/// Keep only the values that are in both d1 and d2
/// both the key and the value must match to be kept
/// keyword: intersection
pub fun keep-shared(d1: dict<k, v>, d2: dict<k, v>, ?v/(==): (v, v) -> e bool, ?k/(==): (k, k) -> e bool) : e dict<k, v>
  val (s, l) = order(d1, d2)
  l.keep-if fn(k1, v1) s.get(k1).maybe(False, fn(v2) v1 == v2)

/// Adds/keeps only the values that are not shared between d1 and d2
/// both the key and the value must match to be exluded
/// keyword: symmetric difference
pub fun with-unique(d1: dict<k, v>, d2: dict<k, v>, ?v/(==): (v, v) -> e bool, ?k/(==): (k, k) -> e bool) : e dict<k, v>
  d1.add-all(d2).drop-all(d1.keep-shared(d2))

/// Keep only the values that are in both d1 and d2
/// only the key must match to be kept
/// keyword: intersection
pub fun keep-shared-keys(d1: dict<k, v>, d2: dict<k, v>, ?(==): (k, k) -> e bool) : e dict<k, v>
  val (s, l) = order(d1, d2)
  l.keep-if fn(k, _) s.has-key(k)

/// Keep only the values that are not shared between d1 and d2
/// only the key must match to be kept
/// keyword: symmetric difference
pub fun with-unique-keys(d1: dict<k, v>, d2: dict<k, v>, ?(==): (k, k) -> e bool) : e dict<k, v>
  d1.add-all(d2).drop-all(d1.keep-shared-keys(d2))


// nice to haves

pub fun keys(d: dict<k, v>) : list<k>
  d.unzip().fst

pub fun values(d: dict<k, v>) : list<v>
  d.unzip().snd

pub fun is-empty(d: dict<k, v>) : bool
  d.is-nil

pub fun has-key(d: dict<k, v>, key: k, ?(==): (k, k) -> e bool) : e bool
  d.find(fn((k, _)) k == key).bool

pub fun has-value(d: dict<k, v>, value: v, ?(==): (v, v) -> e bool) : e bool
  d.find(fn((_, v)) v == value).bool

pub fun list(d: dict<k, v>) : list<(k, v)>
  d
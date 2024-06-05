import test
import std/core/undiv

pub effect yield<a>
  ctl yield(value: a) : ()

pub alias sequence<a,e> = () -> <yield<a>|e> ()

pub fun yield-all( seq : sequence<a,e> ) : <yield<a>|e> ()
  seq()

// loops forever, calling onEach each iteration
pub fun loop(onEach)
  fn()
    while { True }
      yield(onEach())

// seems like it could cause api surface problems
// but here for those who need it
// pub fun repeat(value)
//   loop { value }

pub fun map(seq, onEach)
  fn()
    with fun yield(x)
      yield(onEach(x))
    seq()

pub fun flatmap(seq, onEach)
  fn()
    with fun yield(x)
      onEach(x).seq/seq.yield-all
    seq()

fun test-flatmap()
  with test
  [1, 2, 3].seq.flatmap(fn(a) ['a', 'b']).list.assert-eq(['a', 'b', 'a', 'b', 'a', 'b'])

pub fun intersperse(seq, value)
  seq.flatmap(fn(a) [value, a]).skip(1)

fun test-intersperse()
  with test
  [].seq.intersperse(0).list.assert-eq([])
  [1, 2, 3].seq.intersperse(0).list.assert-eq([1, 0, 2, 0, 3])

pub fun foreach( seq : sequence<a,e>, onEach: (a) -> e () ) : e ()
  with fun yield(a)
    onEach(a)
  seq()

// todo: rename?
// yield values until False is returned from onEach
// keyword: drop-while
pub fun while(seq, onEach)
  fn()
    with ctl yield(value)
      if onEach(value) then
        yield(value)
        resume(())
    seq()

// keyword: reduce
// keyword: fold
pub fun walk( seq : sequence<a,e>, state: s, onEach: (s,a) -> e s ) : e s
  with ctl yield(a)
    onEach(resume(()), a)
  seq()
  state

// todo: better name?
// todo: better, explicit typing and effect management..
pub fun scan(seq, state, onEach)
  fn()
    val s = state.ref
    with fun yield(a)
      s := onEach(!s, a)
      yield(!s)
    seq()

pub fun limit(seq, amount)
  fn()
    var i := 0
    with ctl yield(a)
      if i < amount then
        i := i + 1
        yield(a)
        resume(())
    seq()

pub fun all( seq : sequence<a,e>, predicate : (a) -> e bool ) : e bool
  with ctl yield(a)
    if !predicate(a) then False else resume(())
  seq()
  True

fun test-all()
  with test
  [1, 2, 3, 4, 5].seq.all(fn(a) a < 6).assert-eq(True)
  [1, 2, 3, 4, 5].seq.all(fn(a) a < 3).assert-eq(False)

pub fun any( seq : sequence<a,e>, predicate : (a) -> e bool ) : e bool
  with ctl yield(a)
    if predicate(a) then True else resume(())
  seq()
  False

fun test-any()
  with test
  [1, 2, 3, 4, 5].seq.any(fn(a) a < 3).assert-eq(True)
  [1, 2, 3, 4, 5].seq.any(fn(a) a > 6).assert-eq(False)

// keyword: drop
pub fun skip(seq, n)
  fn()  
    var i := 0
    with fun yield(value)
      if i >= n then yield(value)
      i := i + 1
    seq()

fun test-skip()
  with test
  [1, 2, 3, 4, 5].seq.skip(0).list.assert-eq([1, 2, 3, 4, 5])
  [1, 2, 3, 4, 5].seq.skip(2).list.assert-eq([3, 4, 5])
  [1, 2, 3, 4, 5].seq.skip(8).list.assert-eq([])

pub fun count( seq : sequence<a,e> ) : e int
  seq.walk(0, fn(s, _) s + 1)

fun test-count()
  with test
  [].seq.count.assert-eq(0)
  [1, 2, 3, 4].seq.count.assert-eq(4)

pub fun extend( seq-a : sequence<a,e>, seq-b : sequence<a,e> ) : sequence<a,e>
  fn()
    seq-a.yield-all
    seq-b.yield-all

pub fun unzip( seq : sequence<(a, b),e> ) : e (sequence<a,e>, sequence<b,e>)
  seq.walk((seq/empty(), seq/empty())) fn((seq-a, seq-b), (a, b))
    (a.single.extend(seq-a), b.single.extend(seq-b))

fun test-unzip()
  with test
  val (a, b) = [(1, 'a'), (2, 'b'), (3, 'c')].seq.unzip
  (a.list, b.list).assert-eq { ([1, 2, 3],['a', 'b', 'c']) }

pub fun single( value : a ) : sequence<a,e>
  fn() yield(value)

pub fun empty() : sequence<a,e>
  fn() ()

// todo: better name
// keyword: product (?)
pub fun combine(a, b)
  fn()
    handle a fun yield(a')
      handle b fun yield(b')
        yield((a', b'))

// additional functionality

pub fun list( seq : sequence<a,e> ) : e list<a>
  with ctl yield(x) Cons(x, resume(()))
  seq()
  Nil

pub fun list/seq( list : list<a> ) : sequence<a,e>
  fn() list.foreach(yield)

pub fun list/yield-all( list : list<a> ) : yield<a> ()
  list.seq.yield-all

// tests
fun test-loop()
  with test
  var i := 0
  loop({ i := i + 1; i })
    .limit(5)
    .list
    .assert-eq([1, 2, 3, 4, 5])

fun test-map()
  with test
  [1, 2, 3, 4].seq.map(fn(a) a + 2).list.assert-eq([3, 4, 5, 6])

fun test-foreach()
  with test
  var i := 0
  [1, 2, 3, 4].seq.foreach fn(a) i := i + a
  i.assert-eq(10)

fun test-while()
  with test
  [1, 2, 3, 4, 2].seq.while(fn(a) a < 3).list.assert-eq([1, 2])

// todo: rename to take-while or stop-once
fun test-while-usage()
  while { [1, 2, 3, 4, 2].yield-all } fn(a) a < 3

fun test-limit()
  with test
  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].seq.limit(5).list.assert-eq([1, 2, 3, 4, 5])

fun test-walk()
  with test
  [1, 2, 3, 4].seq.walk(0, fn(a, b) a + b).assert-eq(10)

fun test-scan()
  with test
  [1, 2, 3, 4, 5].seq.scan(0, (+)).list.assert-eq([1, 3, 6, 10, 15])

fun test-combine()
  with test
  [1, 2, 3].seq.combine(['a', 'b'].seq).list.assert-eq
    [(1,'a'),(1,'b'),(2,'a'),(2,'b'),(3,'a'),(3,'b')]
  
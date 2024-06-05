import test
import std/core/undiv

pub effect yield<a>
  ctl yield(value: a) : ()

pub alias sequence<a,e> = () -> <yield<a>|e> ()

pub fun yield-all( seq : sequence<a,e> ) : <yield<a>|e> ()
  seq()

// ----------------------------------------------------------------------------
// Sequence functions
// ----------------------------------------------------------------------------

// # Creation

pub fun single( value : a ) : sequence<a,e>
  fn() yield(value)

pub fun empty() : sequence<a,e>
  fn() ()

// loops forever, calling onEach each iteration
pub fun loop(onEach)
  fn()
    while { True }
      yield(onEach())

// # Chaining

pub fun map( seq : sequence<a,_>, onEach: (a) -> _ _ ) : sequence<_, _>
  fn()
    with fun yield(x)
      yield(onEach(x))
    seq()

pub fun flatmap( seq : sequence<_,_>, onEach: (_) -> _ list<_>) : sequence<_,_>
  fn()
    with fun yield(x)
      onEach(x).seq/seq.yield-all
    seq()

pub fun intersperse( seq : sequence<_,_>, value : _ ) : sequence<_,_>
  seq.flatmap(fn(a) [value, a]).skip(1)

// todo: rename?
// yield values until False is returned from onEach
// keyword: drop-while
pub fun while( seq : sequence<_,_>, onEach : (_) -> _ bool ) : sequence<_,_>
  fn()
    with ctl yield(value)
      if onEach(value) then
        yield(value)
        resume(())
    seq()

// todo: better name?
// todo: can we remove the need for refs/st?
pub fun scan( seq : sequence<a,<st<h>,yield<b>,div|e>>, state : b, onEach : (b, a) -> <st<h>,div,yield<b>|e> b ) : sequence<b,<st<h>,div|e>>
  fn()
    val s = state.ref
    with fun yield(a)
      s := onEach(!s, a)
      yield(!s)
    seq()

pub fun limit( seq : sequence<_,_>, amount : int ) : sequence<_,_>
  fn()
    var i := 0
    with ctl yield(a)
      if i < amount then
        i := i + 1
        yield(a)
        resume(())
    seq()

// keyword: drop
pub fun skip( seq : sequence<_,_>, amount : int ) : sequence<_,_>
  fn()  
    var i := 0
    with fun yield(value)
      if i >= amount then yield(value)
      i := i + 1
    seq()

pub fun with-index( seq : sequence<_,_> ) : sequence<_,_>
  fn()
    var i := 0
    with fun yield(a)
      i := i + 1
      yield((i, a))
    seq()

pub fun extend( seqA : sequence<a,e>, seqB : sequence<a,e> ) : sequence<a,e>
  fn()
    seqA.yield-all
    seqB.yield-all

// todo: better name
// keyword: product (?)
pub fun combine(a, b)
  fn()
    handle a fun yield(a')
      handle b fun yield(b')
        yield((a', b'))

// # Finishing

pub fun foreach( seq : sequence<a,e>, onEach: (a) -> e () ) : e ()
  with fun yield(a)
    onEach(a)
  seq()

// todo: renamed to "string"?
// todo: generalized join using ?(++) and fold1?
pub fun join( seq: sequence<string,e> ) : e string
  seq.walk("", fn(s, a) s ++ a)

// keyword: reduce
// keyword: fold
pub fun walk( seq : sequence<a,e>, state: s, onEach: (s,a) -> e s ) : e s
  with ctl yield(a)
    onEach(resume(()), a)
  seq()
  state

pub fun all( seq : sequence<a,e>, predicate : (a) -> e bool ) : e bool
  with ctl yield(a)
    if !predicate(a) then False else resume(())
  seq()
  True

pub fun any( seq : sequence<a,e>, predicate : (a) -> e bool ) : e bool
  with ctl yield(a)
    if predicate(a) then True else resume(())
  seq()
  False

pub fun find( seq: sequence<a,e>, predicate: (a) -> e bool ) : e maybe<a>
  with ctl yield(a)
    if predicate(a) then Just(a) else resume(())
  seq()
  Nothing

pub fun count( seq : sequence<a,e> ) : e int
  seq.walk(0, fn(s, _) s + 1)

// # Splitting
 
pub fun unzip( seq : sequence<(a, b),e> ) : e (sequence<a,e>, sequence<b,e>)
  seq.walk((seq/empty(), seq/empty())) fn((seq-a, seq-b), (a, b))
    (a.single.extend(seq-a), b.single.extend(seq-b))

// ----------------------------------------------------------------------------
// List functions
// ----------------------------------------------------------------------------

pub fun list( seq : sequence<a,e> ) : e list<a>
  with ctl yield(x) Cons(x, resume(()))
  seq()
  Nil

pub fun list/seq( list : list<a> ) : sequence<a,e>
  fn() list.foreach(yield)

pub fun list/yield-all( list : list<a> ) : yield<a> ()
  list.seq.yield-all

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

fun test-all()
  with test
  [1, 2, 3, 4, 5].seq.all(fn(a) a < 6).assert-eq(True)
  [1, 2, 3, 4, 5].seq.all(fn(a) a < 3).assert-eq(False)

fun test-any()
  with test
  [1, 2, 3, 4, 5].seq.any(fn(a) a < 3).assert-eq(True)
  [1, 2, 3, 4, 5].seq.any(fn(a) a > 6).assert-eq(False)

fun test-combine()
  with test
  [1, 2, 3].seq.combine(['a', 'b'].seq).list.assert-eq
    [(1,'a'),(1,'b'),(2,'a'),(2,'b'),(3,'a'),(3,'b')]

fun test-combine-empty()
  with test
  ([] : list<int>).seq.combine([1, 2, 3].seq).list.assert-eq([])

fun test-count()
  with test
  [].seq.count.assert-eq(0)
  [1, 2, 3, 4].seq.count.assert-eq(4)

fun test-find()
  with test
  [].seq.find(fn(a) a > 3).assert-eq(Nothing)
  [1, 2, 3, 4, 5].seq.find(fn(a) a > 3).assert-eq(Just(4))

fun test-flatmap()
  with test
  [1, 2, 3].seq.flatmap(fn(a) ['a', 'b']).list.assert-eq(['a', 'b', 'a', 'b', 'a', 'b'])

fun test-foreach()
  with test
  var i := 0
  [1, 2, 3, 4].seq.foreach fn(a) i := i + a
  i.assert-eq(10)

fun test-intersperse()
  with test
  [].seq.intersperse(0).list.assert-eq([])
  [1, 2, 3].seq.intersperse(0).list.assert-eq([1, 0, 2, 0, 3])

pub fun test-join()
  with test
  [].join.assert-eq("")
  ["h", "e", "ll", "o"].join.assert-eq("hello")

fun test-limit()
  with test
  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].seq.limit(5).list.assert-eq([1, 2, 3, 4, 5])

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

fun test-scan()
  with test
  [1, 2, 3, 4, 5].seq.scan(0, (+)).list.assert-eq([1, 3, 6, 10, 15])

fun test-skip()
  with test
  [1, 2, 3, 4, 5].seq.skip(0).list.assert-eq([1, 2, 3, 4, 5])
  [1, 2, 3, 4, 5].seq.skip(2).list.assert-eq([3, 4, 5])
  [1, 2, 3, 4, 5].seq.skip(8).list.assert-eq([])

fun test-unzip()
  with test
  val (a, b) = [(1, 'a'), (2, 'b'), (3, 'c')].seq.unzip
  (a.list, b.list).assert-eq { ([1, 2, 3],['a', 'b', 'c']) }

fun test-walk()
  with test
  [1, 2, 3, 4].seq.walk(0, fn(a, b) a + b).assert-eq(10)

fun test-with-index()
  with test
  ['a', 'b', 'c'].seq.with-index.list.assert-eq([(1, 'a'), (2, 'b'), (3, 'c')])

fun test-while()
  with test
  [1, 2, 3, 4, 2].seq.while(fn(a) a < 3).list.assert-eq([1, 2])

// todo: rename to take-while or stop-once
fun test-while-usage()
  while { [1, 2, 3, 4, 2].yield-all } fn(a) a < 3
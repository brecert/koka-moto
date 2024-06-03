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

pub fun foreach( seq : sequence<a,e>, onEach: (a) -> e () ) : e ()
  with fun yield(a)
    onEach(a)
  seq()

// todo: rename?
// yield values until False is returned from onEach
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

pub fun join( seq-a : sequence<_,_>, seq-b : sequence<_,_> ) : sequence<_,_>
  fn()
    seq-a.yield-all
    seq-b.yield-all

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
  
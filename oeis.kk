import seq
import test

pub val zeros = a000004
pub fun a000004() : sequence<_,_>
  loop { 0 }

pub val ones = a000012
pub fun a000012() : sequence<_,_>
  loop { 1 }

pub val nats = a000027
pub fun a000027() : sequence<_,_>
  ones().scan(0, (+))

pub val fibonacci = a000045
pub fun a000045() : sequence<_,_>
  nats().scan((0, 1), fn((a, b), _) (b, a + b)).map(fst)

// utility for creating generalized fibonacci sequences
inline fun n-acci(init : list<int>) : (() -> sequence<_,_>)
  fn() init.seq.extend(nats().scan(init, fn(list, _) list.tail ++ [list.sum]).map(head).map(unjust))

pub val a000073 = n-acci([0, 0, 1])
pub val a000213 = n-acci([1, 1, 1])
pub val a001590 = n-acci([0, 1, 0])

pub fun test-n-acci-usage()
  a000073().limit(100).list

pub fun test-nats()
  with test
  nats().limit(5).list.assert-eq([1, 2, 3, 4, 5])

pub fun test-fibonacci()
  with test
  fibonacci().limit(10).list.assert-eq([1,1,2,3,5,8,13,21,34,55])


import seq

// pause, operate on individual steps, then continue a sequence
// unfinished

struct step<a,e>( continue : () -> e maybe<(a, step<a,e>)> )

fun next( s : step<a,e> ) : e maybe<(a,step<a,e>)>
  (s.continue)()

fun step( seq : sequence<a,e> ) : step<a,e>
  Step
    with ctl yield(a)
      Just((a, Step{resume(())}))
    seq()
    Nothing

fun seq( s : step<a,<div,yield<a>|e>> ) : sequence<a,<div|e>>
  fun yield-all(s')
    match s'.step/next
      Nothing -> ()
      Just((a, rest)) -> 
        yield(a)
        rest.yield-all
  fn() s.yield-all

fun main()
  val nums = [1, 2, 3, 4, 5]
  nums.seq.map(fn(a) a + 2).step.next.unjust.fst
  
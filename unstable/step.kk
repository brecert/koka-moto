import seq
import test

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

fun seq/zip(a, b)
  fun yield-zipped(sa, sb)
    match (sa.step/next, sb.step/next)
      (Just((value-a, rest-a)), Just((value-b, rest-b))) ->
        yield((value-a, value-b))
        yield-zipped(rest-a, rest-b)
      (_, _) -> ()
  fn() yield-zipped(a.step, b.step)

fun test-zip()
  with test
  [1, 2, 3].seq
    .zip(['a', 'b', 'c'].seq)
    .zip([-1, -2, -3].seq)
    .list
    .assert-eq([((1,'a'),-1),((2,'b'),-2),((3,'c'),-3)])


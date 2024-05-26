pub fun maybe/const( default : a ) : total (( x : b ) -> e maybe<a>)
  fn(_) Just(default)

pub fun maybe-empty/const( default : a ) : total (() -> e maybe<a>)
  fn() Just(default)

pub fun empty/const( default : a ) : total (() -> e a)
  fn() default

rec type term
  Lam(f: term -> term)
  Pi(a: term, f: term -> term)
  App(m: term, n: term)
  Ann(m: term, a: term)
  Var(x: int)
  Star
  Boxx

fun term/show(term: term, level = 0)
  match term
    Lam(f)    -> "(λ" ++ f(Var(level)).show(level + 1) ++ ")"
    Pi(a, f)  -> "(Π" ++ a.show ++ "." ++ f(Var(level)).show(level + 1) ++ ")"
    App(m, n) -> "(" ++ m.show ++ " " ++ n.show ++ ")"
    Ann(m, a) -> "(" ++ m.show ++ ":" ++ a.show ++ ")"
    Var(x)    -> x.show
    Star      -> "*"
    Boxx      -> "☐"


import std/core/debug

pub fun debug( value: v, ?show : v -> string, ?kk-file-line : string ) : v
  trace-show(value)
  value
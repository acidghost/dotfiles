# Utilities for the NU language.

# Negates the given closure or the input.
export def negate [pred?: closure] {
  if $pred != null {
    do $pred | not $in
  } else { not $in }
}

# Repeat action f n times.
export def repeat [n, f] { seq 1 $n | each $f }

# An S-combinator, equivalent to `x(in, y(in))`.
export def "comb s" [x: closure, y: closure, arg?: any] {
  let z = if $arg == null { $in } else { $arg };
  do $x $z (do $y $z)
}

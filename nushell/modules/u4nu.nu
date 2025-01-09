# Utilities for the NU language.

# Negates the given closure or the input.
export def negate [pred?: closure] {
  if $pred != null {
    do $pred | not $in
  } else { not $in }
}

# Repeat action f n times.
export def repeat [n, f] { seq 1 $n | each $f }

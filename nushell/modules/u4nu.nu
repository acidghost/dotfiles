# Utilities for the NU language.

# Negates the given closure or the input.
export def negate [pred?: closure] {
  if $pred != null {
    do $pred | not $in
  } else { not $in }
}

# Check for NOT empty values.
export def is-not-empty [] { negate {is-empty} }

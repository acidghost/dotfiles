# List installed packages.
export def list [
  --formula
  --cask
  ...args
] {
  mut args = $args
  if $formula {
    $args = ($args | append "--formula")
  }
  if $cask {
    $args = ($args | append "--cask")
  }
  ^brew list ...$args | lines | wrap name
}

# List installed formulae.
export alias formulae = list --formula
# List installed casks.
export alias casks = list --cask

# List users of package.
export def uses [pkg] { ^brew uses --installed $pkg | lines }
# List dependencies of package.
export def deps [pkg] { ^brew deps --installed $pkg | lines }

# Add users of packages.
export def "with uses" [] { par-each { |x| $x | upsert uses (uses $x.name) } }
# Add dependencies of packages.
export def "with deps" [] { par-each { |x| $x | upsert deps (deps $x.name) } }

# List installed formulae with their users.
export def "list uses" [] { formulae | with uses }
# List installed formulae with their dependencies.
export def "list deps" [] { formulae | with deps }

# Filter packages by number of users.
export def "filter uses" [
  --less-than(-l)
  n: int = 0
] {
  if $less_than {
    where ($it.uses | length) < $n
  } else {
    where ($it.uses | length) == $n
  }
}
# Filter unused packages.
export def "filter unused" [] { filter uses 0 }
export def unused [] { list uses | filter unused | get name }

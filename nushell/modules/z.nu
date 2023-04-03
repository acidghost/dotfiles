# A port of z.sh to nu.
export def main [
  --time(-t): string@"nu-complete z t"      # Sort by recent access
  --rank(-r): string@"nu-complete z r"      # Sort by rank (i.e. how much time is spent)
  q?: string@"nu-complete z"                # Sort by frecency
] {
  let path = (
    if not ($q    | is-empty) { $q } else
    if not ($time | is-empty) { $time } else
    if not ($rank | is-empty) { $rank } else
    { error make { msg: 'No argument given' } })
  commandline --replace $"cd ($path)"
}

def "nu-complete z"   [] { z list    | z-list-complete frecency }
def "nu-complete z t" [] { z list -t | z-list-complete time }
def "nu-complete z r" [] { z list -r | z-list-complete rank }

def z-list-complete [attr: string] {
  reverse | each { |x| { value: $x.path description: ($x | get $attr) } }
}

def epochseconds [] { date now | date format %s | into int }

# List all directories by 'frecency'.
export def "z list" [
  --time(-t)                # Sort by recent access
  --rank(-r)                # Sort by rank (i.e. how much time is spent)
  --raw                     # Do not compute frecency score
] {
  let dirs = (open ~/.z | from csv -s '|' -n | rename path rank time)
  if $raw { return $dirs }
  let epochseconds = epochseconds
  $dirs | par-each { |dir|
    let dx = $epochseconds - $dir.time
    let frecency = 10000 * $dir.rank * (3.75 / ((0.0001 * $dx + 1) + 0.25))
    $dir | insert frecency ($frecency | into int)
  } | sort-by (if $time { 'time' } else if $rank { 'rank' } else { 'frecency' })
}

# Use FZF to seach the list of 'frecent' directories.
export def "z fzf" [
  --dry-run(-n)             # Just output the selection
  term: string = ""         # Term to start the query with
] {
  let sel = (z list | reverse
    | each { |it| ($it.frecency | fill -w 10) + ' ' + $it.path }
    | str join (char -i 0)
    | fzf --read0 --reverse --preview 'tree -aC --gitignore -I .git {2}' -q $term
    | parse "{frecency} {path}" | str trim)

  if ($sel | is-empty) { return }
  let sel = $sel.0
  if $dry_run { return $sel }

  commandline --replace $"cd ($sel.path)"
}

def "z store" [dirs: table] {
  let csv = ($dirs | to csv -s '|' -n)
  let tmp = (mktemp $"($env.HOME)/.z.nu.XXXXXX" | str trim)
  try {
    $csv | save -f $tmp
  } catch { |e|
    rm -f $tmp
    print $e
  }
  mv -f $tmp ~/.z
}

# Add a path to the datafile and refresh it.
export def "z add" [
  --dry-run(-n)             # Don't store updated datafile
  p: path                   # Path to upsert in the datafile
] {
  if not ($p | path exists) {
    error make { msg: $"Path ($p) does not exist" }
  } else if ($p | path type) != 'dir' {
    error make { msg: $"Path ($p) is not a directory" }
  }

  let res = (z list --raw | reduce -f { xs: [] tot_rank: 0 added: false } { |dir, acc|
    if not ($dir.path | path exists) or $dir.rank < 1 {
      $acc
    } else if $dir.path != $p {
      { xs: ($acc.xs ++ $dir) tot_rank: ($acc.tot_rank + $dir.rank) added: $acc.added }
    } else {
      let dir = ($dir | update rank ($dir.rank + 1))
      { xs: ($acc.xs ++ $dir) tot_rank: ($acc.tot_rank + $dir.rank) added: true }
    }
  })

  mut tot_rank = $res.tot_rank

  let dirs = if $res.added {
    $res.xs
  } else {
    $tot_rank += 1
    $res.xs ++ { path: $p rank: 1 time: (epochseconds) }
  }

  let dirs = if $tot_rank > 9000 {
    $dirs | update rank { |dir| $dir.rank * 0.99 }
  } else {
    $dirs
  }

  if $dry_run { return $dirs }
  z store $dirs
}

export def "z rm" [
  --dry-run(-n)             # Don't store updated datafile
  --recursive(-R)           # Remove also all subdirectories
  p: path                   # Path to remove from the datafile
] {
  let dirs = (z list --raw | filter (if $recursive {
    { |dir| not ($dir.path | str starts-with $p) }
  } else {
    { |dir| $dir.path != $p }
  }))

  if $dry_run { return $dirs }
  z store $dirs
}

export def "z test rm" [--recursive(-R) p: path] {
  let old = z list --raw
  let new = if $recursive { z rm $p -n -R } else { z rm $p -n }
  let deleted = ($old | each { |dir| $dir not-in $new })
  let deleted_idx = ($deleted | enumerate | each { |it| if $it.item { $it.index } })
  $old | enumerate | where index in $deleted_idx
}

export-env {
  let-env config = ($env | default {} config).config

  let-env config = ($env.config | default {} hooks)
  let-env config = ($env.config | update hooks ($env.config.hooks | default [] pre_execution))
  let-env config = ($env.config | update hooks.pre_execution { |c|
    $c.hooks.pre_execution | append {
      if $env.PWD != $env.HOME {
        z add $env.PWD
      }
    }
  })

  let-env config = ($env.config | default [] keybindings)
  let-env config = ($env.config | update keybindings { |c|
    $c.keybindings | append {
      name: znu_jump
      modifier: control
      keycode: char_j
      mode: [emacs, vi_normal, vi_insert]
      event: { send: ExecuteHostCommand cmd: "z fzf (commandline)" }
    }
  })
}

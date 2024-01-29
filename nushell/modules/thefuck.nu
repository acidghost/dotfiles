# Integrates thefuck with nushell.

# Invoke thefuck and replace commandline with selection.
export def fuck [
  --yes(-y)             # Automatically select the first option
  ...args               # Custom arguments to pass to thefuck
] {
  load-env {
    TF_SHELL: 'nushell'
    TF_ALIAS: 'fuck'
    TF_SHELL_ALIASES: ($nu.scope.aliases
      | update expansion { |a| $a.expansion | lines | str join ' ' }
      | format pattern '{name}={expansion}' | to text)
    TF_HISTORY: (history | last 10 | get command | to text)
    PYTHONENCODING: 'utf-8'
  }
  commandline --replace (if $yes {
    # Stdout from thefuck is not printed to nushell's stdout
    do { ^thefuck THEFUCK_ARGUMENT_PLACEHOLDER ($args | append '--yes') }
  } else {
    # Allow the user to interact with thefuck
    run-external --redirect-stdout thefuck THEFUCK_ARGUMENT_PLACEHOLDER $args
  })
}

export-env {
  $env.config = ($env.config | upsert keybindings { |config|
    $config.keybindings | append {
      name: fuck
      modifier: control
      keycode: char_k
      mode: [emacs, vi_normal, vi_insert]
      event: { send: ExecuteHostCommand cmd: "fuck -y" }
    }
  })
}

export alias kk = fuck

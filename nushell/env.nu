# Nushell Environment Config File

const prompt_provider = 'starship'
mkdir ~/.cache/nushell

if $prompt_provider == 'starship' {
  starship init nu | save -f ~/.cache/nushell/prompt.nu
  $env.PROMPT_INDICATOR = { || "" }
  $env.PROMPT_INDICATOR_VI_INSERT = { || "" }
  $env.PROMPT_INDICATOR_VI_NORMAL = { || "" }
  $env.PROMPT_MULTILINE_INDICATOR = { || "::: " }
} else {
  '' | save -f ~/.cache/nushell/prompt.nu

  def create_left_prompt [] {
      let path_segment = if (is-admin) {
          $"(ansi red_bold)($env.PWD)"
      } else {
          $"(ansi green_bold)($env.PWD)"
      }

      $path_segment
  }

  def create_right_prompt [] {
      let time_segment = ([
          (date now | date format '%m/%d/%Y %r')
      ] | str join)

      $time_segment
  }

  $env.PROMPT_COMMAND = { || create_left_prompt }
  $env.PROMPT_COMMAND_RIGHT = { || create_right_prompt }
}

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
let config_dir = ($nu.config-path | path dirname)
$env.NU_LIB_DIRS = [
    ($config_dir | path join 'scripts')
    ($config_dir | path join 'modules')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

# XXX: const does not work without explicitly expanding the path at each use
# const dynamic_env_src = '~/.cache/nushell/dynamic_env.nu'
let dynamic_env_src = $env.HOME + '/.cache/nushell/dynamic_env.nu'
rm -f $dynamic_env_src
touch $dynamic_env_src

# Check if a program (i.e. not a built-in) exists.
def "program exists" [cmd] {
  not (which -a $cmd | where not built-in | is-empty)
}

seq 1 10 | each { |x| [
  $"alias dh($x) = du -d ($x - 1)"
  $"alias tree($x) = tree -L ($x)"
]} | flatten | save --append $dynamic_env_src

if (program exists brew) {
  "use brew.nu\n" | save --append $dynamic_env_src
}

if (program exists thefuck) {
  "use thefuck.nu *\n" | save --append $dynamic_env_src
}

const forgit = '~/.antigen/bundles/wfxr/forgit/bin/git-forgit'
if ($forgit | path exists) {
  $"$env.FORGIT = '($forgit)'\nuse forgit.nu *\n" | save --append $dynamic_env_src
}

if (program exists nnn) {
  "use nnn.nu *\n" | save --append $dynamic_env_src
}

if ('~/.config/broot/launcher/nushell/br' | path exists) {
  "source ~/.config/broot/launcher/nushell/br\n" | save --append $dynamic_env_src
}

if (program exists zoxide) {
  zoxide init nushell | save -f ~/.cache/nushell/zoxide.nu
  "source ~/.cache/nushell/zoxide.nu
  $env.config = ($env.config | update keybindings { |c|
    $c.keybindings | append {
      name: zoxide_jump
      modifier: control
      keycode: char_j
      mode: [emacs, vi_normal, vi_insert]
      event: { send: ExecuteHostCommand cmd: 'zi (commandline)' }
    }
  })
  " | save --append $dynamic_env_src
} else {
  "use z.nu *\n" | save --append $dynamic_env_src
}

if (program exists atuin) {
  atuin init nu --disable-up-arrow | save -f ~/.cache/nushell/atuin.nu
  "source ~/.cache/nushell/atuin.nu\n" | save --append $dynamic_env_src
}

if (program exists zk) {
  "alias zke = zk edit -ix daily
   alias zked = zk edit -i
   alias zki = zk index
   alias zkl = zk list
   alias zkli = zk list -i
   alias zkd = zk daily
   alias zkcd = cd $env.ZK_NOTEBOOK_DIR
  " | save --append $dynamic_env_src
}

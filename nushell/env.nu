# Nushell Environment Config File

let prompt_provider = 'starship'
mkdir ~/.cache/nushell

if $prompt_provider == 'starship' {
  starship init nu | save -f ~/.cache/nushell/prompt.nu
  let-env PROMPT_INDICATOR = { "" }
  let-env PROMPT_INDICATOR_VI_INSERT = { "" }
  let-env PROMPT_INDICATOR_VI_NORMAL = { "" }
  let-env PROMPT_MULTILINE_INDICATOR = { "::: " }
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

  let-env PROMPT_COMMAND = { create_left_prompt }
  let-env PROMPT_COMMAND_RIGHT = { create_right_prompt }
}

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
let-env ENV_CONVERSIONS = {
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
let-env NU_LIB_DIRS = [
    ($config_dir | path join 'scripts')
    ($config_dir | path join 'modules')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
let-env NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# let-env PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

# Dynamic aliases
seq 1 10 | each { |x| [
  $"alias dh($x) = du -d ($x - 1)"
  $"alias tree($x) = tree -L ($x)"
]} | flatten | save -f ~/.cache/nushell/aliases.nu

let custom_sources = $'($env.HOME)/.cache/nushell/custom_sources.nu'
rm -f $custom_sources
touch $custom_sources

if not ($env.ASDF_DIR | is-empty) {
  "source '" + $env.ASDF_DIR + "/asdf.nu'" | save --append $custom_sources
}

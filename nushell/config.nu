# Nushell Config File

use u4nu.nu *

$env.config = {
  history: {
    max_size: 100_000 # Session has to be reloaded for this to take effect
    sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
    file_format: "plaintext" # "sqlite" or "plaintext"
  }
  filesize: {
    metric: true # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
  }
  edit_mode: vi

  hooks: {
    display_output: {
      if (term size).columns >= 100 { table -e } else { table }
    }
  }
  menus: [
    {
      name: completion_menu
      only_buffer_difference: false
      marker: "| "
      type: {
        layout: columnar
        columns: 4
        col_width: 20     # Optional value. If missing all the screen width is used to calculate column width
        col_padding: 2
      }
      style: {
        text: green
        selected_text: { attr: r }
        description_text: yellow
        match_text: { attr: u }
        selected_match_text: { attr: ur }
      }
    }
    {
      name: ide_completion_menu
      only_buffer_difference: false
      marker: "| "
      type: {
        layout: ide
        min_completion_width: 0,
        max_completion_width: 50,
        max_completion_height: 10, # will be limited by the available lines in the terminal
        padding: 0,
        border: true,
        cursor_offset: 0,
        description_mode: "prefer_right"
        min_description_width: 0
        max_description_width: 50
        max_description_height: 10
        description_offset: 1
        # If true, the cursor pos will be corrected, so the suggestions match up with the typed text
        #
        # C:\> str
        #      str join
        #      str trim
        #      str split
        correct_cursor_pos: false
      }
      style: {
        text: green
        selected_text: { attr: r }
        description_text: yellow
        match_text: { attr: u }
        selected_match_text: { attr: ur }
      }
    }
    {
      name: history_menu
      only_buffer_difference: true
      marker: "? "
      type: {
        layout: list
        page_size: 10
      }
      style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
      }
    }
    {
      name: help_menu
      only_buffer_difference: true
      marker: "? "
      type: {
        layout: description
        columns: 4
        col_width: 20
        col_padding: 2
        selection_rows: 4
        description_rows: 10
      }
      style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
      }
    }
    # Example of extra menus created using a nushell source
    # Use the source field to create a list of records that populates
    # the menu
    {
      name: commands_menu
      only_buffer_difference: false
      marker: "# "
      type: {
        layout: columnar
        columns: 4
        col_width: 20
        col_padding: 2
      }
      style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
      }
      source: { |buffer, position|
        scope commands
        | where name =~ $buffer
        | each { |it| {value: $it.name description: $it.usage} }
      }
    }
    {
      name: vars_menu
      only_buffer_difference: true
      marker: "# "
      type: {
        layout: list
        page_size: 10
      }
      style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
      }
      source: { |buffer, position|
        scope variables
        | where name =~ $buffer
        | sort-by name
        | each { |it| {value: $it.name description: $it.type} }
      }
    }
  ]
  keybindings: [
    {
      name: completion_menu
      modifier: none
      keycode: tab
      mode: [emacs vi_normal vi_insert]
      event: {
        until: [
          { send: menu name: completion_menu }
          { send: menunext }
          { edit: complete }
        ]
      }
    }
    {
      name: ide_completion_menu
      modifier: control
      keycode: char_n
      mode: [emacs vi_normal vi_insert]
      event: {
        until: [
          { send: menu name: ide_completion_menu }
          { send: menunext }
          { edit: complete }
        ]
      }
    }
    {
      name: completion_previous
      modifier: shift
      keycode: backtab
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menuprevious }
    }
    {
      name: unix-line-discard
      modifier: control
      keycode: char_u
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          {edit: cutfromlinestart}
        ]
      }
    }
    {
      name: kill-line
      modifier: control
      keycode: char_k
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          {edit: cuttolineend}
        ]
      }
    }
    # Keybindings used to trigger the user defined menus
    {
      name: commands_menu
      modifier: control
      keycode: char_t
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: commands_menu }
    }
    {
      name: vars_menu
      modifier: control
      keycode: char_v
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: vars_menu }
    }
    # Custom
    {
      name: config_reload
      modifier: control
      keycode: char_q
      mode: [emacs, vi_normal, vi_insert]
      event: [
        { edit: Clear }
        { edit: InsertString value: "config reload" }
        { send: Enter }
      ]
    }
    {
      name: history_fzf
      modifier: control
      keycode: char_r
      mode: [emacs, vi_normal, vi_insert]
      event: { send: ExecuteHostCommand cmd: "history fzf (commandline)" }
    }
  ]
}


source ~/.cache/nushell/prompt.nu
source ~/.cache/nushell/dynamic_env.nu


alias .. = cd ".."
alias ... = cd "../.."
alias .... = cd "../../.."

alias la = ls -a
alias ll = ls -l

alias md = mkdir
alias rd = rmdir

alias g     = git
alias ga    = git add
alias gb    = git branch
alias gc    = git commit --verbose
alias gd    = git diff
alias gds   = git diff --staged
alias gf    = git fetch
alias gl    = git pull
alias gp    = git push
alias gr    = git remote

# Wraps git status
def gst [...args] {
  ^git status --short ...$args
    | from ssv --noheaders --minimum-spaces 1
    | rename status filename
}

# Wraps git log
def glo [...args] {
  ^git log --oneline --decorate --color=always $args
    | lines | reverse | parse "{hash} {txt}"
}

# Reload nu configuration.
def "config reload" [] { exec nu }

# Explore commandline history via FZF.
def "history fzf" [term: string = ""] {
  history | get command | reverse | uniq | str join (char -i 0)
    | fzf --read0 --reverse --height '40%' -q $term
    | decode utf-8 | str trim
    | commandline edit $in
}

# Get the current Git branch name (from oh-my-zsh)
def git-current-branch [] {
  let symref = (do { git symbolic-ref --quiet HEAD } | complete)
  if ($symref.stdout | is-empty) {
    if $symref.exit_code == 128 { return }
    git rev-parse --short HEAD err> /dev/null
  } else {
    $symref.stdout
  } | str trim | str replace "refs/heads/" ""
}

def bat [...args] {
  let cmd = if (which --all bat | where type == external | length) > 0 {
    'bat'
  } else if (which --all batcat | where type == external | length) > 0 {
    'batcat'
  } else {
    error make {msg: "bat is not installed"}
  }
  let file_args = $args | filter {|f| $f | path exists} | length
  if $file_args > 1 {
    let style = if ($env | get -i BAT_STYLE | is-not-empty) {
      $"($env.BAT_STYLE),header"
    } else {
      'header'
    }
    ^$cmd $"--style=($style)" ...$args
  } else {
    ^$cmd ...$args
  }
}

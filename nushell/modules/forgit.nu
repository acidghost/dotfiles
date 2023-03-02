# Generate forgit commands
export def "forgit self gen-commands" [] {
  forgit self commands | each { |cmd|
    let decl = ($'"forgit ($cmd | str replace -a "_" " ")"' | fill -w 32)
    $'export def ($decl) [...args] { run-external $env.FORGIT ($cmd) $args }'
  } | to text
}

# Generate forgit aliases
export def "forgit self gen-aliases" [] {
  forgit self commands | each { |cmd|
    let item = (env | where name == $"forgit_($cmd)")
    if not ($item | is-empty) {
      $"export alias ($item.0.value | fill -w 12) = ($item.0.name | str replace '_' ' ')"
    }
  } | to text
}

def "forgit self commands" [] {
  run-external --redirect-stdout $env.FORGIT | lines | find --regex '^\s+' | str trim
}

############ The following is auto-generated

export def "forgit add"                     [...args] { run-external $env.FORGIT add $args }
export def "forgit blame"                   [...args] { run-external $env.FORGIT blame $args }
export def "forgit branch delete"           [...args] { run-external $env.FORGIT branch_delete $args }
export def "forgit checkout branch"         [...args] { run-external $env.FORGIT checkout_branch $args }
export def "forgit checkout commit"         [...args] { run-external $env.FORGIT checkout_commit $args }
export def "forgit checkout file"           [...args] { run-external $env.FORGIT checkout_file $args }
export def "forgit checkout tag"            [...args] { run-external $env.FORGIT checkout_tag $args }
export def "forgit cherry pick"             [...args] { run-external $env.FORGIT cherry_pick $args }
export def "forgit cherry pick from branch" [...args] { run-external $env.FORGIT cherry_pick_from_branch $args }
export def "forgit clean"                   [...args] { run-external $env.FORGIT clean $args }
export def "forgit diff"                    [...args] { run-external $env.FORGIT diff $args }
export def "forgit fixup"                   [...args] { run-external $env.FORGIT fixup $args }
export def "forgit ignore"                  [...args] { run-external $env.FORGIT ignore $args }
export def "forgit log"                     [...args] { run-external $env.FORGIT log $args }
export def "forgit rebase"                  [...args] { run-external $env.FORGIT rebase $args }
export def "forgit reset head"              [...args] { run-external $env.FORGIT reset_head $args }
export def "forgit revert commit"           [...args] { run-external $env.FORGIT revert_commit $args }
export def "forgit stash show"              [...args] { run-external $env.FORGIT stash_show $args }
export def "forgit stash push"              [...args] { run-external $env.FORGIT stash_push $args }

export alias fga          = forgit add
export alias gbl          = forgit blame
export alias gbd          = forgit branch_delete
export alias gcb          = forgit checkout_branch
export alias gco          = forgit checkout_commit
export alias gcf          = forgit checkout_file
export alias gct          = forgit checkout_tag
export alias gcp          = forgit cherry_pick
export alias fgclean      = forgit clean
export alias fgd          = forgit diff
export alias gfu          = forgit fixup
export alias fgi          = forgit ignore
export alias fglo         = forgit log
export alias grb          = forgit rebase
export alias fgrh         = forgit reset_head
export alias grc          = forgit revert_commit
export alias fgss         = forgit stash_show
export alias gsp          = forgit stash_push

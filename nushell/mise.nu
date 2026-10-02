def "parse vars" [] {
  $in | from csv --noheaders --no-infer | rename 'op' 'name' 'value'
}

def --env "update-env" [] {
  for $var in $in {
    if $var.op == "set" {
      if ($var.name =~ '(?i)^path$') {
        $env.PATH = ($var.value | split row (char esep))
      } else {
        load-env {($var.name): $var.value}
      }
    } else if $var.op == "hide" {
      try { hide-env $var.name }
    }
  }
}
export-env {
  $env.__MISE_ORIG_PATH = r#'/Users/polireddi.manideep/.pi/agent/bin:/Users/polireddi.manideep/.asdf/plugins/nodejs/shims:/Users/polireddi.manideep/.asdf/installs/nodejs/25.2.1/bin:/Users/polireddi.manideep/.asdf/shims:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/go/bin/:/Users/polireddi.manideep/.local/bin/:/Users/polireddi.manideep/go/bin:/Users/polireddi.manideep/Library/Android/sdk/platform-tools:/Users/polireddi.manideep/Library/Android/sdk/emulator:/Users/polireddi.manideep/google-cloud-sdk/bin:/Users/polireddi.manideep/fvm/default/bin/cache/dart-sdk/bin:/Users/polireddi.manideep/.local/bin:/Users/polireddi.manideep/.cargo/bin:/Users/polireddi.manideep/.opencode/bin:/Library/TeX/texbin:/Users/polireddi.manideep/Documents/code/personal/muzic:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin'#
$env.PATH = (r#'/Users/polireddi.manideep/.local/share/mise/shims:/Users/polireddi.manideep/.pi/agent/bin:/Users/polireddi.manideep/.asdf/plugins/nodejs/shims:/Users/polireddi.manideep/.asdf/installs/nodejs/25.2.1/bin:/Users/polireddi.manideep/.asdf/shims:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/go/bin/:/Users/polireddi.manideep/.local/bin/:/Users/polireddi.manideep/go/bin:/Users/polireddi.manideep/Library/Android/sdk/platform-tools:/Users/polireddi.manideep/Library/Android/sdk/emulator:/Users/polireddi.manideep/google-cloud-sdk/bin:/Users/polireddi.manideep/fvm/default/bin/cache/dart-sdk/bin:/Users/polireddi.manideep/.local/bin:/Users/polireddi.manideep/.cargo/bin:/Users/polireddi.manideep/.opencode/bin:/Library/TeX/texbin:/Users/polireddi.manideep/Documents/code/personal/muzic:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin'# | split row (char esep))

  '' | parse vars | update-env
  $env.MISE_SHELL = "nu"
  let mise_hook = {
    condition: { "MISE_SHELL" in $env }
    code: { mise_hook }
  }
  add-hook hooks.pre_prompt $mise_hook
  add-hook hooks.env_change.PWD $mise_hook
}

def --env add-hook [field: cell-path new_hook: any] {
  let field = $field | split cell-path | update optional true | into cell-path
  let old_config = $env.config? | default {}
  let old_hooks = $old_config | get $field | default []
  $env.config = ($old_config | upsert $field ($old_hooks ++ [$new_hook]))
}

export def --env --wrapped main [command?: string, --help, ...rest: string] {
  let commands = ["deactivate", "shell", "sh"]

  if ($command == null) {
    ^"/opt/homebrew/bin/mise"
  } else if ($command == "activate") {
    $env.MISE_SHELL = "nu"
  } else if ($command in $commands) {
    ^"/opt/homebrew/bin/mise" $command ...$rest
    | parse vars
    | update-env
  } else {
    ^"/opt/homebrew/bin/mise" $command ...$rest
  }
}

def --env mise_hook [] {
  ^"/opt/homebrew/bin/mise" hook-env -s nu
    | parse vars
    | update-env
}


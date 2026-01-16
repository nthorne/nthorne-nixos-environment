{
  lib,
  pkgs,
  ...
}: {
  # https://nixos.wiki/wiki/Zsh
  # https://home-manager-options.extranix.com/?query=zsh&release=release-24.11

  programs.zsh = {
    enable = true;

    enableCompletion = true;

    autocd = true;

    localVariables = {
      BLACK = ''%{"$'\033[01;30m'"%}'';
      GREEN = ''%{"$'\033[01;32m'"%}'';
      RED = ''%{"$'\033[01;31m'"%}'';
      YELLOW = ''%{"$'\033[01;33m'"%}'';
      BLUE = ''%{"$'\033[01;34m'"%}'';
      BOLD = ''%{"$'\033[01;39m'"%}'';
      NORM = ''%{"$'\033[00m'"%}'';
    };

    shellAliases = {
      ls = "eza";
      l = "eza -al --git --no-user --time-style=long-iso --no-permissions --group-directories-first --header";
      grep = "grep --color=auto";
      vim = "nvim";
      view = "nvim -R";
      _ = "sudo";
      less = "less -R";
      md = "mkdir";
      fd = "fd -H";
      today = "todoist --color l -f '(today|overdue)'";
      worktoday = "todoist --color l -f '#work&(today|overdue)'";
    };

    sessionVariables = {
      EDITOR = "nvim";
      EXINIT = "set ai sm sw=2 sts=2 bs=2 showmode ruler guicursor=a:blinkon0";
      LSOPT = "--color=auto";
      LS_COLORS = "ow=01;35:di=01;35";
      PAGER = "${lib.getExe pkgs.less}";
      SSH_ASKPASS = "";
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=23";
    };

    history = {
      # path defaults to ~/.zsh_history
      size = 50000;
      save = 40000;
      expireDuplicatesFirst = true;
      ignoreSpace = true;
      ignoreDups = true;
    };

    plugins = [
      # Keybinding is not working.
      {
        name = pkgs.jq-zsh-plugin.pname;
        src = pkgs.jq-zsh-plugin.src;
        file = "jq.plugin.zsh";
      }

      # Configured and working
      {
        name = "zsh-cdr";
        src = pkgs.fetchFromGitHub {
          owner = "willghatch";
          repo = "zsh-cdr";
          rev = "253c8e7ea2d386e95a4f06a78c660b3deee84bb7";
          sha256 = "197rrfzphv4nj943hhnbrigaz4vq49h7zddrdm06cdpq3m98xz0a";
        };
        file = "cdr.plugin.zsh";
      }

      {
        name = "zsh-zaw";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zaw";
          rev = "c8e6e2a4244491a2b89c2524a2030336be8d7c7f";
          sha256 = "103zgzg6s8a9fsmml6vxzawnf0ql24nwjca9wrygr782l0fkraky";
        };
        file = "zaw.zsh";
      }

      {
        name = "zsh-cd-gitroot";
        src = pkgs.fetchFromGitHub {
          owner = "mollifier";
          repo = "cd-gitroot";
          # these details are easy to fetch with nix-prefetch-git ..
          rev = "66f6ba7549b9973eb57bfbc188e29d2f73bf31bb";
          sha256 = "00aj9z3fa6ghjpz7s9cdqpfy4vh1v19z284p4f7xj0z40vrlbdx4";
        };
        file = "cd-gitroot.plugin.zsh";
      }

      {
        name = pkgs.zsh-autosuggestions.pname;
        src = pkgs.zsh-autosuggestions.src;
      }

      {
        name = pkgs.zsh-completions.pname;
        src = pkgs.zsh-completions.src;
      }

      {
        name = pkgs.zsh-nix-shell.pname;
        src = pkgs.zsh-nix-shell.src;
      }
    ];

    # .zshenv
    envExtra = ''
    '';

    # .zshrc
    initContent = ''
      ### .zshrc
      ###   - sourced for interactive shells
      ###

      function error()
      {
        echo "error: $@" 1>&2
        return 1
      }

      ### }}}
      ### completions {{{
      ###

      # partial completion suggestions
      zstyle ':completion:*' list-suffixes zstyle ':completion:*' expand prefix suffix

      # case insensitive path-completion
      zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

      ### }}}
      ### general settings {{{
      ###

      export FZF_DEFAULT_OPTS="
      --layout=reverse
      --info=inline
      --height=80%
      --multi
      --preview '([[ -f {} ]] && (cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
      --color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'
      --bind '?:toggle-preview'
      --preview-window=hidden
      "

      autoload edit-command-line

      zle -N globalias
      zle -N rationalise-dot
      zle -N edit-command-line

      # set the DISPLAY variable automatically, using the IP address from SSH_CONNECTION
      export DISPLAY="`echo $SSH_CONNECTION | awk '{print $1}'`:0.0"

      ### }}}
      ### function definitions {{{
      ###

      function globalias () {
        # Expand upper-case global aliases
        if [[ $LBUFFER =~ ' [A-Z0-9]+$' ]]
        then
          zle _expand_alias
          zle expand-word
        fi
        zle self-insert
      }

      function rationalise-dot () {
        if [[ $LBUFFER =~ '[ \/]\.\.$' ]]
        then
          LBUFFER+=/..
        else
          LBUFFER+=.
        fi
      }
      # }}}


      ### }}}
      ### aliases {{{
      ###

      #global aliases
      alias -g C='| wc -l'
      alias -g F='| fgrep'
      alias -g FI='| fgrep -i'
      alias -g FV='| fgrep -v'
      alias -g G='| egrep'
      alias -g H='| head'
      alias -g L='| less'
      alias -g S='| sort'
      alias -g T='| tail'
      alias -g EN="2>/dev/null"
      alias -g ON="1>/dev/null"

      # .. order matters here.
      alias -g ......='cd ../../../../../..'
      alias -g .....='cd ../../../../..'
      alias -g .....='cd ../../../..'
      alias -g ....='cd ../../..'
      alias -g ...='cd ../..'

      # suffix aliases
      alias -s cpp=vim
      alias -s hpp=vim
      alias -s json=${lib.getExe pkgs.jless}
      alias -s md=${lib.getExe pkgs.bat}
      alias -s yml=${lib.getExe pkgs.bat}
      alias -s yaml=${lib.getExe pkgs.bat}

      ### }}}
      ### Key bindings {{{
      ###

      # use vi keybindings
      bindkey -v

      # we need to re-set this one because of bindkey -v,
      # and bindkey -v cannot take place before plugins
      # section, or my vim keybindings will be messed up.
      bindkey '^X;' zaw

      bindkey '^Xk' run-help

      bindkey "^[[1;5C" forward-word

      # keybindings for alias expansion
      bindkey " " globalias               # expand on space
      bindkey "^ " magic-space            # <C-space> to bypass expansion
      bindkey -M isearch " " magic-space  # use normal space during searches

      bindkey '^r' history-incremental-search-backward

      bindkey '^j' jq-complete

      # keybinding for dot expansion
      bindkey . rationalise-dot

      bindkey '^X^e' edit-command-line

      bindkey '^X_' undo

      # Some git convenience bindings
      bindkey -s '^Xga' 'git add -p .'
      bindkey -s '^Xgc' 'git commit -m ""\e[D'

      ### }}}
      ### Options {{{
      ###
      setopt MAGIC_EQUAL_SUBST
      setopt GLOB_COMPLETE
      unsetopt CASE_GLOB
      unsetopt CASE_MATCH
      setopt GLOB_ASSIGN
      setopt GLOB_STAR_SHORT

      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

      ### }}}

      eval "$(direnv hook zsh)"

      ### UNDER EVALUATION {{{
      ###

      function _fasd_z_to_subfolder() {
        test -z "''${1}" && echo "Missing subfolder argument." && return

        readonly subfolder=$(fasd -dl1 "''${PWD}" "''${1}")
        test -z  "''${subfolder}" && echo "''${1}: no such subfolder in fasd." && return
        test -d "''${subfolder}" || return

        cd "''${subfolder}"
      }

      function take()
      {
        test -d "''${1}" || mkdir -p "''${1}"
        test -d "''${1}" || error "unable to create ''${1}"
        cd "''${1}"
      }

      function taked()
      {
        readonly pth="$(date +%Y-%m-%d)-''${1}"
        test -d "''${pth}" || mkdir -p "''${pth}"
        test -d "''${pth}" || error "unable to create ''${pth}"
        cd "''${pth}"
      }

      ## >>> This snippet is roughly from oh-my-zsh/fasd, in an attempt
      ##     to drop the framework entirely.
      export ZSH_CACHE_DIR="''${HOME}/.cache/zsh"
      test -d "''${ZSH_CACHE_DIR}" || mkdir -p "''${ZSH_CACHE_DIR}"

      # check if fasd is installed
      if (( ''${+commands[fasd]} )); then
        fasd_cache="''${ZSH_CACHE_DIR}/fasd-init-cache"
        if [[ "$commands[fasd]" -nt "$fasd_cache" || ! -s "$fasd_cache" ]]; then
          fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install \
            zsh-wcomp zsh-wcomp-install >| "$fasd_cache"
        fi
        source "$fasd_cache"
        unset fasd_cache

        alias v='f -e "$EDITOR"'
        alias o='a -e xdg-open'
        alias j='zz'
        alias zs=_fasd_z_to_subfolder
      fi

      ## <<<

      test -f "''${zgen_base_path}/sachaos/todoist-master/todoist_functions_fzf.sh" && \
        . "''${zgen_base_path}/sachaos/todoist-master/todoist_functions_fzf.sh"

      ### }}}
    '';

    # .zprofile
    profileExtra = ''
      ### .zprofile
      ###   - sourced for login shells
      ###


      ### }}}
      ### general settings {{{
      ###

      # turn off bell for login shells too.
      #xset b off

      #export PAGER="/bin/less -sR"
      #export TERM="screen-256color"

      export PATH="$HOME:bin/:$PATH:$HOME/.local/bin"

      # For shellcheck
      export PATH=$PATH:/home/nthorne/.cabal/bin/
    '';
  };
}

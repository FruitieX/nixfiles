{ pkgs, ... }:

{
  # Fish shell configuration
  enable = true;

  interactiveShellInit = ''
    # Launch in tmux session if we're not already in one
    if not test $TMUX
      exec tmux new-session -t 0 \; set-option destroy-unattached
    end

    # Fish vi keybindings with jj mapped to normal mode
    fish_vi_key_bindings
    bind -M insert -m default jj force-repaint

    # LS colors
    eval (${pkgs.coreutils}/bin/dircolors "${./dircolors.base16.dark}" | sed "s/LS_COLORS=/set LS_COLORS /")
  '';

  promptInit = ''
    set normal (set_color normal)
    set magenta (set_color magenta)
    set yellow (set_color yellow)
    set green (set_color green)
    set red (set_color red)
    set gray (set_color -o black)

    # Fish git prompt
    set __fish_git_prompt_showdirtystate 'yes'
    set __fish_git_prompt_showstashstate 'yes'
    set __fish_git_prompt_showuntrackedfiles 'yes'
    set __fish_git_prompt_showupstream 'yes'
    set __fish_git_prompt_color_branch green
    set __fish_git_prompt_color_dirtystate blue
    set __fish_git_prompt_color_upstream_ahead yellow
    set __fish_git_prompt_color_upstream_behind yellow

    # Status Chars
    set __fish_git_prompt_char_dirtystate '*'
    set __fish_git_prompt_char_stagedstate '+'
    set __fish_git_prompt_char_untrackedfiles 'u'
    set __fish_git_prompt_char_stashstate 's'
    set __fish_git_prompt_char_upstream_ahead '>'
    set __fish_git_prompt_char_upstream_behind '<'
    set __fish_git_prompt_char_upstream_prefix ""

    function fish_prompt
      set last_status $status

      set_color $fish_color_cwd
      printf '%s' (prompt_pwd)
      set_color normal

      printf '%s ' (__fish_git_prompt)

      set_color normal
    end
  '';

  # Git aliases, adapted from https://github.com/sorin-ionescu/prezto/blob/master/modules/git/alias.zsh
  shellAliases = {
    g = "git";

    # Branch (b)
    gb = "git branch";
    gbc = "git checkout -b";
    gbd = "git branch --delete";

    # Commit (c)
    gc = "git commit --verbose";
    gca = "git commit --verbose --all";
    gcm = "git commit --message";
    gco = "git checkout";
    gcf = "git commit --amend --reuse-message HEAD";
    gcp = "git cherry-pick --ff";

    # Fetch (f)
    gf = "git fetch";
    gfc = "git clone";
    gfm = "git pull";
    gfr = "git pull --rebase";
    gl = "gfm";

    # Index (i)
    gia = "git add";
    giA = "git add --patch";
    gir = "git reset";

    # Log (l)
    gls = "git log --topo-order --stat --pretty=format:\"%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B\"";
    glg = "git log --topo-order --all --graph --pretty=format:\"%C(green)%h%C(reset) %s%C(red)%d%C(reset)%n\"";

    # Push (p)
    gp = "git push";
    gpf = "git push --force-with-lease";
    gpF = "git push --force";
    gpc = "git push --set-upstream origin (git symbolic-ref HEAD 2> /dev/null | sed s-refs/heads/--)";

    # Rebase (r)
    gr = "git rebase";
    gra = "git rebase --abort";
    grc = "git rebase --continue";
    gri = "git rebase --interactive";
    grs = "git rebase --skip";

    # Stash (s)
    gs = "git stash";
    gsp = "git stash pop";

    # Working Copy (w)
    gws = "git status --short";
    gwd = "git diff --no-ext-diff";
  };
}
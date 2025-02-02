set_prompt() {
  local hour_min_sec='%F{240}%*%f'
  local separator='%F{240} | %f'
  local current_directory='%F{blue}%1d%f'

  local git_branch
  local git_changes

  if [ -d ".git" ]; then
    # Read the short, abbreviated name of the current git object
    git_branch=$(echo "$separator%F{magenta}$(git rev-parse --abbrev-ref HEAD)%f")

    # Read the file names of all files in the diff, count the words, trim the whitespace & only show if non-zero
    git_changes=$(git diff --name-only | wc -w | tr -d ' ')
    git_changes=$(if [[ $git_changes != '0' ]]; then echo "%F{240}($git_changes)%f"; fi)
  fi

  # Only show the elapsed time of the previous command if one exists
  if [[ $1 != "" ]]; then
    command_elapsed="$separator%F{cyan}$1ms%f"
  fi

  PROMPT="$hour_min_sec $current_directory$git_branch$git_changes$command_elapsed "
}

before_exec() {
  command_timer=$(($(print -P %D{%s%6.}) / 1000))
}

before_cmd() {
  if [ $command_timer ]; then
    local now=$(($(print -P %D{%s%6.}) / 1000))
    elapsed=$(($now - $command_timer))

    unset command_timer
  fi

  set_prompt $elapsed
}

setopt PROMPT_SUBST
set_prompt

# Shell events
autoload -Uz add-zsh-hook
add-zsh-hook preexec before_exec
add-zsh-hook precmd before_cmd

# Command history search
bindkey "^[f" history-beginning-search-forward  # opt+left
bindkey "^[b" history-beginning-search-backward # opt+right

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

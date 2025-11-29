# ----------------------------------------------------------
# BASIC PROMPT
#
# ----------------------------------------------------------
# %n                -> username
# %m                -> hostname
# %~                -> current directory
# %F{color} ... %f  -> colors
# %#                -> prompt symbol (# for root, % for user)
#
# ----------------------------------------------------------
# USEFUL PROMPT COMPONENTS
#
# %~    -> current directory
# %d    -> full path
# %n    -> username
# %m    -> hostname
# %?    -> exit code of last command
# %*    -> time
# $'\n' -> newline
#
# ----------------------------------------------------------




# ----------------------------------------------------------
# POWERLINE STYLE PROMPT
# ----------------------------------------------------------


# ----------------------------------------------------------
# CONSTANTS

# Icons
ICON_JOINT=""
ICON_I_JOINT=""
ICON_GIT_BRANCH=""
ICON_GIT_STAGED=""
ICON_GIT_DIRTY=""
ICON_GIT_UNTRACKED=""
ICON_GIT_AHEAD=""
ICON_GIT_BEHIND=""
ICON_GIT_DIVERGED=""
ICON_GIT_CLEAN=""

# Colors
WHITE=15
GREY=238
BLUE=12
PURPLE=93
GREEN=71
YELLOW=220

TEXT_COLOR=$WHITE
USER_COLOR=$GREY
DIR_COLOR=$BLUE
GIT_COLOR=$PURPLE
GIT_CLEAN_COLOR=$GREEN
GIT_DIRTY_COLOR=$YELLOW
END_COLOR=$WHITE

# Close
RESET="%f%k"

# ----------------------------------------------------------
# UTIL FUNCTIONS

# --------------------------------------
# Joint

render_joint() {
  local current_color=$1
  local next_color=$2

  printf "%%F{%s}" "$current_color"
  [[ -n $next_color ]] && printf "%%K{%s}" "$next_color"
  printf "%s%%{%s%%}" "$ICON_JOINT" "$RESET"
}

# --------------------------------------
# Segment

render_segment() {
  local bg_color=$1
  local text_color=$2
  local text=$3

  printf "%%F{%s}%%K{%s} %s %%{%s%%}" "$text_color" "$bg_color" "$text" "$RESET"
}

# --------------------------------------
# End Segment

render_end_segment() {
  local current_color=$1
  local end_color=$2

  render_joint "$current_color" "$end_color"
  render_joint "$end_color" "$end_color"
  render_joint "$end_color"
}

# --------------------------------------
# Git Info

git_state() {
  # Return immediately if not in repo
  git rev-parse --is-inside-work-tree &>/dev/null || return 1

  local git_status ahead behind diverged branch

  # Branch name
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

  # Get porcelain status (machine-readable)
  git_status=$(git status --porcelain=2 --branch 2>/dev/null)

  # Detect staged changes (index)
  local staged=0
  if echo "$git_status_raw" | grep -qE "^[12] [A-Z]"; then
    staged=1
  fi

  # Detect unstaged changes
  local dirty=0
  if echo "$git_status_raw" | grep -qE "^[12] .[MD]"; then
    dirty=1
  fi

  # Detect untracked files
  local untracked=0
  if echo "$git_status_raw" | grep -qE "^\?"; then
    untracked=1
  fi

  # Detect upstream ahead/behind
  ahead=$(echo "$git_status_raw"  | sed -n 's/^# branch.ab +\([0-9]*\) -[0-9]*/\1/p')
  behind=$(echo "$git_status_raw" | sed -n 's/^# branch.ab +[0-9]* -\([0-9]*\)/\1/p')

  local relation=""
  if [[ -n "$ahead" && -n "$behind" ]]; then
    relation="diverged"
  elif [[ "$ahead" -gt 0 ]]; then
    relation="ahead"
  elif [[ "$behind" -gt 0 ]]; then
    relation="behind"
  else
    relation=""
  fi

  # All clean?
  local clean=0
  if [[ $staged -eq 0 && $dirty -eq 0 && $untracked -eq 0 ]]; then
    clean=1
  fi

  # Export variables into Zsh associative array
  typeset -gA GIT_INFO=(
    branch "$branch"
    staged $staged
    dirty $dirty
    untracked $untracked
    ahead "$ahead"
    behind "$behind"
    relation "$relation"
    clean $clean
  )

  return 0
}


# ----------------------------------------------------------
# SEGMENTS

# USER segment
segment_user() {
  render_segment $USER_COLOR $TEXT_COLOR "%n"
  render_joint $USER_COLOR $DIR_COLOR
}

# DIRECTORY segment
segment_dir() {
  render_segment $DIR_COLOR $TEXT_COLOR "%~"

  if git rev-parse --is-inside-work-tree &>/dev/null; then
    render_joint $DIR_COLOR $GIT_COLOR
  else
    render_end_segment $DIR_COLOR $END_COLOR
  fi
}

# GIT segment
segment_git() {
  git_state || return

  local branch="${GIT_INFO[branch]}"
  [[ -z $branch ]] && return

  local icons=""

  # CLEAN branch
  if [[ ${GIT_INFO[clean]} -eq 1 ]]; then
    icons="$icons $ICON_GIT_CLEAN"
  fi

  # DIRTY branch
  if [[ ${GIT_INFO[dirty]} -eq 1 ]]; then
    icons="$icons $ICON_GIT_DIRTY"
  fi

  # STAGED changes
  if [[ ${GIT_INFO[staged]} -eq 1 ]]; then
    icons="$icons $ICON_GIT_STAGED"
  fi

  # UNTRACKED changes
  if [[ ${GIT_INFO[untracked]} -eq 1 ]]; then
    icons="$icons $ICON_GIT_UNTRACKED"
  fi

  # AHEAD, BEHIND, DIVERGED
  case "${GIT_INFO[relation]}" in
    ahead)    icons="$icons $ICON_GIT_AHEAD" ;;
    behind)   icons="$icons $ICON_GIT_BEHIND" ;;
    diverged) icons="$icons $ICON_GIT_DIVERGED" ;;
  esac

  # Choose background color based on clean/dirty
  local end_color=$GIT_CLEAN_COLOR
  if [[ ${GIT_INFO[clean]} -eq 0 ]]; then
    end_color=$GIT_DIRTY_COLOR
  fi

  render_segment $GIT_COLOR $TEXT_COLOR "$ICON_GIT_BRANCH $branch"
  render_end_segment $GIT_COLOR $end_color
}

# --------------------------------------
# PROMPT

build_prompt() {
  segment_user
  segment_dir
  segment_git
}

PROMPT='$(build_prompt)'

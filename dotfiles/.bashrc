#!/bin/bash

# Default .bashrc
# Original Author: Samuel Roeca
#
# Use this file to:
#   Import .profile and ~/.bash/sensitive (using the provided "include")
#   Execute some "basic" commands
#   Define bash aliases and functions
#   Note: do NOT place sensitive information (like passwords) in this file
# if using vim:
#   za: toggle one fold
#   zi: toggle all folds

#######################################################################
# Set up environment and PATH
#######################################################################

# Functions --- {{{

path_ladd() {
  # Takes 1 argument and adds it to the beginning of the PATH
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="$1${PATH:+":$PATH"}"
  fi
}

path_radd() {
  # Takes 1 argument and adds it to the end of the PATH
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="${PATH:+"$PATH:"}$1"
  fi
}

today(){
  #shows today's date
  echo -n "Today's date is:"
  date +"%A, %B %-d, %Y"
}

vfz(){
  #opens file in vim using fzf
  fzf_return=$(fzf)
  if [ $? == "0" ]; then
    vim $fzf_return
  fi
}

cfz(){
  #changes to parent directory of file found by fzf
  fzf_return=$(fzf)
  parent_directory=$(echo $fzf_return | rev | cut -d'/' -f2- | rev)
  if [ $? == "0" ]; then
     echo "Navigated to: $parent_directory"
     cd $parent_directory
  fi
}

function nth_row() {
  # 1st arg: s3 path
  # 2nd arg: row # that triggered the stl load error
  # example: nth_row s3://testingcopy/zliu/test.csv 32
  # to extract and display the 32nd row of this file
  local filename=$(basename -- "$1")
  local extension="${filename##*.}"
  # fiq: file in question
  local local_filename="fiq.${filename}"

  # copy the s3 file to local box
  aws s3 cp $1 $local_filename

  # deal with compressed file
  local proceed=true
  local comp_type=$(file $local_filename)
  if [[ "$comp_type" == *"bzip2"* ]]; then
    bzip2 -d $local_filename
    # trim the extension because it's decompressed
    local local_filename=${local_filename%.*}
  elif [[ "$comp_type" == *"gzip"* ]]; then
    gunzip $local_filename
    # trim the extension because it's decompressed
    local local_filename=${local_filename%.*}
  else
    if [[ $extension != "csv" && $extension != "tsv" && $extension != "json" ]]; then
      tput setaf 1;
      echo -e "Attention: this file is of $extension extension!"
      echo -e "Can't deal with '$comp_type' this type of file yet!"
      proceed=false
    fi
  fi

  if [[ $proceed = "true" ]]; then
    # extract the row that caused the issue
    local txt_type=$(file $local_filename)
    local total_lines=$(wc -l < $local_filename)
    if (( $2 > $total_lines )); then
      tput setaf 1;
      echo -e "The line you want to see exceed total lines $total_lines"
      proceed=false
    else
      echo "========== See data below =========="
      if [[ "$txt_type" == *"JSON"* ]]; then
        sed "${2}q;d" $local_filename | jq
      else
        sed "${2}q;d" $local_filename
      fi
    fi
  fi

  # clean-up: remove the downloaded files immediately in case it has PII info
  if [ -f $local_filename ]; then
    rm $local_filename
  fi
  if [[ $proceed = "false" ]]; then
    false
  fi
}
# }}}
# Exported variable: LS_COLORS --- {{{

# Colors when using the LS command
# NOTE:
# Color codes:
#   0   Default Colour
#   1   Bold
#   4   Underlined
#   5   Flashing Text
#   7   Reverse Field
#   31  Red
#   32  Green
#   33  Orange
#   34  Blue
#   35  Purple
#   36  Cyan
#   37  Grey
#   40  Black Background
#   41  Red Background
#   42  Green Background
#   43  Orange Background
#   44  Blue Background
#   45  Purple Background
#   46  Cyan Background
#   47  Grey Background
#   90  Dark Grey
#   91  Light Red
#   92  Light Green
#   93  Yellow
#   94  Light Blue
#   95  Light Purple
#   96  Turquoise
#   100 Dark Grey Background
#   101 Light Red Background
#   102 Light Green Background
#   103 Yellow Background
#   104 Light Blue Background
#   105 Light Purple Background
#   106 Turquoise Background
# Parameters
#   di 	Directory
LS_COLORS="di=1;34:"
#   fi 	File
LS_COLORS+="fi=0:"
#   ln 	Symbolic Link
LS_COLORS+="ln=1;36:"
#   pi 	Fifo file
LS_COLORS+="pi=5:"
#   so 	Socket file
LS_COLORS+="so=5:"
#   bd 	Block (buffered) special file
LS_COLORS+="bd=5:"
#   cd 	Character (unbuffered) special file
LS_COLORS+="cd=5:"
#   or 	Symbolic Link pointing to a non-existent file (orphan)
LS_COLORS+="or=31:"
#   mi 	Non-existent file pointed to by a symbolic link (visible with ls -l)
LS_COLORS+="mi=0:"
#   ex 	File which is executable (ie. has 'x' set in permissions).
LS_COLORS+="ex=1;92:"
# additional file types as-defined by their extension
LS_COLORS+="*.rpm=90"

# Finally, export LS_COLORS
export LS_COLORS

# }}}
# Exported variables: General --- {{{

# React
export REACT_EDITOR='less'

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Configure less (de-initialization clears the screen)
# Gives nicely-colored man pages
export PAGER=less
export LESS='--ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --clear-screen'
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# tmuxinator
export EDITOR=vim
export SHELL=bash

# environment variable controlling difference between HI-DPI / Non HI_DPI
# turn off because it messes up my pdf tooling
export GDK_SCALE=0

# History: ignore leading space commands, keep lines in memory
export HISTCONTROL=ignorespace
export HISTSIZE=5000

# }}}
# Path appends + Misc env setup --- {{{

HOME_BIN="$HOME/bin"
if [ -d "$HOME_BIN" ]; then
  path_ladd "$HOME_BIN"
fi

# EXPORT THE FINAL, MODIFIED PATH
export PATH="/home/prestonng/.asdf/installs/poetry/1.2.0/bin:$PATH"
export PATH

# }}}

#######################################################################
# Interactive Bash session settings
#######################################################################

# Import from other Bash Files --- {{{

include () {
  [[ -f "$1" ]] && source "$1"
}

include ~/.bash/sensitive

# }}}
# Executed Commands --- {{{

# turn off ctrl-s and ctrl-q from freezing / unfreezing terminal
stty -ixon

# }}}
# Aliases --- {{{

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Make "vim" direct to nvim
alias vim=nvim

# ls aliases
alias ll='ls -alF'
alias l='ls -CF'

# Set copy/paste helper functions
# the perl step removes the final newline from the output
alias pbcopy="perl -pe 'chomp if eof' | xsel --clipboard --input"
alias pbpaste="xsel --clipboard --output"

#git aliases
alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias gco='git checkout '
alias gk='gitk --all&'
alias gx='gitx --all'

#poetry aliases
alias prun='poetry run'

# }}}
# Functions --- {{{

# Example functions...

# Clubhouse story template
clubhouse() {
  echo -e "## Objective\n## Value\n## Acceptance Criteria" | pbcopy
}

# Reload bashrc
so() {
  source ~/.bashrc
}

# }}}
# Bash: prompt (PS1) {{{

PS1_COLOR_BRIGHT_BLUE="\033[38;5;115m"
PS1_COLOR_RED="\033[0;31m"
PS1_COLOR_YELLOW="\033[0;33m"
PS1_COLOR_GREEN="\033[0;32m"
PS1_COLOR_ORANGE="\033[38;5;202m"
# PS1_COLOR_GOLD="\033[38;5;142m"
PS1_COLOR_SILVER="\033[38;5;248m"
PS1_COLOR_RESET="\033[0m"
PS1_BOLD="$(tput bold)"

function ps1_git_color() {
  local git_status
  local branch
  local git_commit
  git_status="$(git status 2> /dev/null)"
  branch="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
  git_commit="$(git --no-pager diff --stat "origin/${branch}" 2>/dev/null)"
  if [[ $git_status == "" ]]; then
    echo -e "$PS1_COLOR_SILVER"
  elif [[ $git_status =~ "not staged for commit" ]]; then
    echo -e "$PS1_COLOR_RED"
  elif [[ $git_status =~ "Your branch is ahead of" ]]; then
    echo -e "$PS1_COLOR_YELLOW"
  elif [[ $git_status =~ "nothing to commit" ]] && \
      [[ -z $git_commit ]]; then
    echo -e "$PS1_COLOR_GREEN"
  else
    echo -e "$PS1_COLOR_ORANGE"
  fi
}

function ps1_git_branch() {
  local git_status
  local on_branch
  local on_commit
  git_status="$(git status 2> /dev/null)"
  on_branch="On branch ([^${IFS}]*)"
  on_commit="HEAD detached at ([^${IFS}]*)"
  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    echo " $branch"
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo " $commit"
  else
    echo ""
  fi
}

function ps1_python_virtualenv() {
  if [[ -z $VIRTUAL_ENV ]]; then
    echo ""
  else
    echo "($(basename "$VIRTUAL_ENV"))"
  fi
}

PS1_DIR="\[$PS1_BOLD\]\[$PS1_COLOR_BRIGHT_BLUE\]\w"
PS1_GIT="\[\$(ps1_git_color)\]\[$PS1_BOLD\]\$(ps1_git_branch)\[$PS1_BOLD\]\[$PS1_COLOR_RESET\]"
PS1_VIRTUAL_ENV="\[$PS1_BOLD\]\$(ps1_python_virtualenv)\[$PS1_BOLD\]\[$PS1_COLOR_RESET\]"
# PS1_USR="\[$PS1_BOLD\]\[$PS1_COLOR_GOLD\]\u@\h"
PS1_END="\[$PS1_BOLD\]\[$PS1_COLOR_GREEN\]$ \[$PS1_COLOR_RESET\]"
PS1="${PS1_DIR} ${PS1_GIT} ${PS1_VIRTUAL_ENV}
${PS1_END}"

# }}}
# ASDF: environment manager setup {{{

source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash

# }}}

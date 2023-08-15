# silence zsh complaint
export BASH_SILENCE_DEPRECATION_WARNING=1

#==========================================#
################## EDITOR ##################
#==========================================#

export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

#==========================================#
############### PATH CONFIG ################
#==========================================#

# remove item from $PATH
path-remove () {
  local IFS=':'
  local NEWPATH
  for DIR in $PATH; do
    if [ "$DIR" != "$1" ]; then
      NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
    fi
  done
  export PATH=${NEWPATH};
}

# add item to end of $PATH, uniquely
path-append () {
  [ -d $1 ] || return 1    # make sure directory exists
  path-remove $1           # remove the directory
  export PATH=${PATH}:${1} # append the directory
}

# add item to beginning of $PATH, uniquely
path-prepend () {
  [ -d $1 ] || return 1     # make sure directory exists
  path-remove $1            # remove the directory
  export PATH=${1}:${PATH}  # append the directory
}

path-append /usr/local/bin
path-append /usr/local/sbin
path-append /usr/bin
path-append /usr/sbin
path-append /bin
path-append /sbin
path-prepend ${HOME}/bin
path-prepend ${HOME}/local/bin
path-prepend ${HOME}/local/sbin

if command -v brew 1>/dev/null 2>&1; then
    eval $(/opt/homebrew/bin/brew shellenv)
fi



#==========================================#
################ CORE UTILS ################
#==========================================#

[ -d ${HOME}/local/lib ]     && export LIBARY_PATH=${LIBRARY_PATH}:${HOME}/local/lib
[ -d ${HOME}/local/lib ]     && export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${HOME}/local/lib
[ -d ${HOME}/local/lib ]     && export LD_RUN_PATH=${LD_RUN_PATH}:${HOME}/local/lib
[ -d ${HOME}/local/include ] && export CPATH=${CPATH}:${HOME}/local/include
[ -d ${CPATH} ]              && export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${CPATH}
[ -d ${CPATH} ]              && export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${CPATH}
[ -d ${HOME}/local/man ]     && export MANPATH=${HOME}/local/man:${MANPATH}

# OSX GNU Coreutils
path-prepend /usr/local/opt/coreutils/libexec/gnubin
if [ -d /usr/local/opt/coreutils/libexec/gnuman ]; then
  export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:$MANPATH
fi

#==========================================#
################## PYTHON ##################
#==========================================#

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"
fi

#==========================================#
################# VISUALS ##################
#==========================================#

# Test for an interactive shell.  There is no need to set anything past this
# point for scp and rcp, and it's important to refrain from outputting anything
# in those cases.
[[ $- != *i* ]] && return

# Tell ls to be colourful
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad
 
# Tell grep to highlight matches
export GREP_OPTIONS='--color=auto'

# History Changes
export HISTIGNORE="&:ls:cd:bg:fg:ll:clear" # ignore these commands in history
export HISTCONTROL="ignoredups"      # ignore duplicates in history
export FIGNORE="~"                   # don't show these prefixes in tab-comp
shopt -s checkwinsize                # keep LINES and COLUMNS up to date

# Git status
function find_git_context() {
  # Based on https://github.com/jimeh/git-aware-prompt

  # Branch
  local BRANCH
  local GIT_BRANCH
  if BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then
    if [[ "$branch" == "HEAD" ]]; then
      BRANCH='detached*'
    fi
    GIT_BRANCH="$BRANCH"
  else
    GIT_BRANCH=""
  fi

  # '*' for dirty
  local STATUS=$(git status --porcelain 2> /dev/null)
  local GIT_DIRTY
  if [[ "$STATUS" != "" ]]; then
    GIT_DIRTY='*'
  else
    GIT_DIRTY=''
  fi

  # Concatenate
  GIT_CONTEXT="${GIT_BRANCH}${GIT_DIRTY}"
}

# Set color of command line terms

function ps1_context {
  # For any of these bits of context that exist, display them and append
  # a space.  Ref: https://gist.github.com/datagrok/2199506
  VIRTUAL_ENV_BASE=`basename "$VIRTUAL_ENV"`
  # "${VIRTUAL_ENV_BASE}" \
  find_git_context
  for v in "${GIT_CONTEXT}" \
             "${debian_chroot}" \
             "${GIT_DIRTY}" \
             "${PS1_CONTEXT}"; do
    echo -n "${v:+$v }"
  done
}

source ~/.bashrc_colors
case "$TERM" in
  xterm*|rxvt*|Eterm*|eterm*|screen*)
    # If the terminal supports colors, then use fancy terminal
    if [ "$LOGNAME" == "root" ]; then
      # root
      PS1='\[${bldred}\]\]\u@\h \[${bldblue}\]\W\n\$ \[${txtrst}\]'
    # elif [ "$SSH_CONNECTION" ]; then
    #   # remote machines
    #   PS1='\[${txtblk}\]$(ps1_context)\[${bldcyn}\]\u@\h \[${bldblu}\]\W\n\$ \[${txtrst}\]'
    else
      # local machine
      PS1='\[${txtpur}\]$(ps1_context)\[${bldgrn}\]\u\[${bldwht}\]@\[${bldylw}\]\h \[${bldcyn}\]\W\n\$ \[${txtrst}\]'
    fi
    ;;
  *)
    # Default no color, no fanciness
    PS1='$ '
    ;;
esac
export PS1

#history -csource /Users/sunnstix/perl5/perlbrew/etc/bashrc

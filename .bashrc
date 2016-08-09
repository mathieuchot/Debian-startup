

export PS1="\[\033[38;5;196m\]\u\[$(tput sgr0)\]\[\033[38;5;226m\]@\[$(tput sgr0)\]\[\033[38;5;81m\]\h\[$(tput sgr0)\]\[\033[38;5;83m\][\[$(tput sgr0)\]\[\033[38;5;202m\]\A\[$(tput sgr0)\]\[\033[38;5;82m\]]\[$(tput sgr0)\]\[\033[38;5;201m\]:\[$(tput sgr0)\]"

export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -lahg'
alias l='ls $LS_OPTIONS -lart'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

alias vi='vim'
alias grep='grep --color=auto'

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# append to the history file, don't overwrite it
shopt -s histappend

export HISTSIZE=20000
export HISTFILESIZE=20000000
export HISTTIMEFORMAT='%d%m%Y %T   '
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac




### functions ###
ext () {
  if [ -z "$1" ]; then
    echo "Usage: ext archive_to_extract"
  else
    if [ -f $1 ] ; then
        case $1 in
          *.tar.bz2)   tar xjvf $1    ;;
          *.tar.gz)    tar xzvf $1    ;;
          *.bz2)       bzip2 -d $1    ;;
          *.rar)       unrar e $1    ;;
          *.gz)        gunzip $1    ;;
          *.tar)       tar xf $1    ;;
          *.tbz2)      tar xjf $1    ;;
          *.tgz)       tar xzf $1    ;;
          *.zip)       unzip $1     ;;
          *.Z)         uncompress $1    ;;
          *.7z)        7z x $1    ;;
          *)           echo "'$1' cannot be extracted via ext()"   ;;
      esac
    else
      echo "'$1' file does not exist"
    fi
  fi
}

nmac(){
  INTERFACE=$(ip route | grep default | cut -d " " -f 5)
  sudo ifdown $INTERFACE
  sudo macchanger -A $INTERFACE
  sudo ifup $INTERFACE
  }
}

upbashrc(){
	rm -rf ~/.bashrc
	wget https://raw.githubusercontent.com/mathieuchot/Debian-startup/master/.bashrc  -O ~/.bashrc 
	. ~/.bashrc
}

upvimrc(){
	sudo rm -rf /etc/vim/vimrc
  	sudo wget https://github.com/mathieuchot/Debian-startup/blob/master/.vimrc -O /etc/vim/vimrc
     	sudo . /etc/vim/vimrc
}

#http://stackoverflow.com/questions/188162/what-is-the-most-useful-script-youve-written-for-everyday-life
up(){
	if [ -z "$1" ]; then
    	echo "Usage: up (int)"
    else
		LIMIT=$1
		P=$PWD
		for ((i=1; i <= LIMIT; i++))
		do
			P=$P/..
		done
		cd $P
		export MPWD=$P
	fi
}
#

back(){
	LIMIT=$1
	P=$MPWD
	for ((i=1; i <= LIMIT; i++))
	do
	    P=${P%/..}
	done
	cd $P
	export MPWD=$P
}

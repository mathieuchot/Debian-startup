EMOJI="if [ \$? = 0 ]; then echo '\[\033[38;5;34m\]:)\[$(tput sgr0)\]'; else echo '\[\033[38;5;88m\]:(\[$(tput sgr0)\]'; fi"
export PS1="\`${EMOJI}\`\[\033[38;5;196m\]\u\[$(tput sgr0)\]\[\033[38;5;226m\]@\[$(tput sgr0)\]\[\033[38;5;81m\]\h\[$(tput sgr0)\]\[\033[38;5;83m\][\[$(tput sgr0)\]\[\033[38;5;202m\]\A\[$(tput sgr0)\]\[\033[38;5;82m\]]\[$(tput sgr0)\]\[\033[38;5;201m\]:\[$(tput sgr0)\]"

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

#bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#alias cu1="oneko -speed 10 -tomoyo -fg red -bg pink"
#alias cu2="oneko -speed 10 -sakura -fg red -bg pink"
#alias cu3="oneko -speed 10 -neko -fg red -bg pink"

alias dfd='find . -type d -print0 | xargs -0 du | sort -n | tail -10 | cut -f2 | xargs -I{} du -sh {}'
alias dff='find . -type f -print0 | xargs -0 du | sort -n | tail -10 | cut -f2 | xargs -I{} du -sh {}'
alias df='df -h --total'

export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -lahg'
alias l='ls $LS_OPTIONS -lart'
alias lsd='ls $LS_OPTIONS -lartd */'
alias catc='pygmentize -g'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

alias vi='vim'
alias grep='grep --color=auto'

alias freecache='free && sync && echo 3 > /proc/sys/vm/drop_caches && free'

alias logs="find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -vE '[0-9]$' | xargs tail -f"

alias wifipass="egrep -h -s -A 9 --color -T 'ssid=' /etc/NetworkManager/system-connections/*"
alias internet="ip route | grep default | cut -d ' ' -f 5"
alias scrot='scrot -s /home/mathieu/Images/scrot_%b%d::%H%M%S.png'

#man bash colored
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

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
	  	  *.xz)	       tar xvJf $1;;
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
  sudo service networking restart

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
#go up in the current path : up 2 == cd 2 folders above
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

#go back in the currentpath : back 1 == go back 1 folder before the go command
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

#Simple Http server serving the current path 
web(){
	if [ -z $1 ] ; then
		python -m SimpleHTTPServer
	else
		case $1 in
    		''|*[!0-9]*) echo "\n Usage: web portnumber \n" ;;
		 	*) iptables -A INPUT -i wlan0 -p tcp --dport $1 -m state --state NEW,ESTABLISHED -j ACCEPT && python -m SimpleHTTPServer $1 ;;
		esac
	fi
	/etc/init.d/firewall.sh restart
}
addusb(){
	sudo echo '\nACTION=="add", ATTR{idVendor}=="$1" RUN+="/bin/sh -c 'echo 1 >/sys$DEVPATH/authorized'"' >> /etc/udev/rules.d/01-usblockdown.rules
}






#!/bin/bash
#author: mathieu chot-plassot
HOST='https://github.com'
CHECK_INTERNET=$(wget --no-check-certificate --spider -nv -S $HOST 2>&1 | grep -m 1 'HTTP/' | cut -d" " -f4)

GREEN="$(tput setaf 2)"
MAGENTA="$(tput setaf 5)"
RED="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
END="$(tput setaf 9)"
echo "${GREEN}-----------------------------------${END}"
echo "${MAGENTA}     ___      __   _           ${END}"
echo "${MAGENTA}    / _ \___ / /  (_)__ ____   ${END}"
echo "${MAGENTA}   / // / -_| _ \/ / _ \/ _ \  ${END}"
echo "${MAGENTA}  /____/\__/\.__/_/\_,_/_//_/  ${END}"
echo "${MAGENTA}   / __/ /____ _____/ /___ _____  ${END}"
echo "${MAGENTA}  _\ \/ __/ _ \/ __/ __/ // / _ \ ${END}"
echo "${MAGENTA} /___/\__/\_,_/_/  \__/\_,_/ .__/ ${END}"
echo "${MAGENTA}                          /_/    ${END}"
echo "${GREEN}-----------------------------------${END}"

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED} \n This script must be run as root \n ${END}" 1>&2
   exit 1
fi

case $CHECK_INTERNET in
    200|302) echo -e "${MAGENTA}[INTERNET]${GREEN} OK ${END}" 1>&2  ;;
    403)    echo -e "${MAGENTA}[INTERNET]${RED} Connexion to $HOST is forbidden ${END}" 1>&2
            exit 1 ;;
    305|407)    echo -e "${MAGENTA}[INTERNET]${RED} Connexion to $HOST has been filtered by a webproxy on your network ${END}" 1>&2
            exit 1 ;;
    404)    echo -e "${MAGENTA}[INTERNET]${RED} The resource $HOST has not been found ${END}" 1>&2
            exit 1 ;;
    *)      echo -e "${MAGENTA}[INTERNET]${RED} An error has been encountered. Error code: $CHECK_INTERNET  ${END}" 1>&2
            exit 1 ;;
esac

Sourcelists(){
   #if arg 1 is not defined arg = ""
   option=${1-""}
   cat <<EOF > /etc/apt/sources.list
deb http://httpredir.debian.org/debian jessie main $option
deb-src http://httpredir.debian.org/debian jessie main $option

deb http://httpredir.debian.org/debian jessie-updates main $option
deb-src http://httpredir.debian.org/debian jessie-updates main $option

deb http://security.debian.org/ jessie/updates main $option
deb-src http://security.debian.org/ jessie/updates main $option

EOF
   apt-get update -y
}

Sourcelistsid(){
cat <<EOF > /etc/apt/sources.list
deb http://ftp.fr.debian.org/debian/ sid main
deb-src http://ftp.fr.debian.org/debian/ sid main
EOF
}

DefaultFiles(){
   echo -e "${BLUE}[1/5]${GREEN} Replacing Default files  \n ${END}" 1>&2
   
   declare -A getfiles=(["bashrc"]="wget -q https://raw.githubusercontent.com/mathieuchot/Debian-startup/master/.bashrc -O ~/.bashrc" ["vimrc"]="wget -q https://raw.githubusercontent.com/mathieuchot/Debian-startup/master/.vimrc -O /etc/vim/vimrc")
   for key in ${!getfiles[@]}; do
       echo -e "${MAGENTA}[DOWNLOAD] ${GREEN} Replacing $key ...\n"
       eval "${getfiles["$key"]}"
       if [ $? -ne 0 ]; then
           echo -e "${MAGENTA}[DOWNLOAD]${RED} failed to replace the file $key. error code: $?  ${END} \n" 1>&2
       else
           echo -e "${MAGENTA}[DOWNLOAD]${GREEN} The file $key has been correctly replaced ${END} \n" 1>&2
       fi
   done
   #destroy current bash instence and create a new one to apply the bashrc conf
   #exec bash
    echo -e "${GREEN} Which Distribution list do you want to use for your sources.list ${END}: \n"
   read -p " ${GREEN} ct(contrib) | stable(default) | nf(non-free ) | cnf(contrib non-free) | sid: ${END}" choice
   case "$choice" in 
     cn ) echo -e "${GREEN} The testing distribution  will be used${END} \n" 1>&2
            Sourcelists "contrib"  ;;
     nf ) echo -e "${GREEN} The unstable distribution will be used${END} \n" 1>&2
            Sourcelists "non-free" ;;
     cnf) echo -e "${GREEN} The testing & unstable distribution will be used${END} \n" 1>&2
            Sourcelists "contrib non-free" ;;
     sid) echo -e "${GREEN} The testing & unstable distribution will be used${END} \n" 1>&2
            Sourcelistsid
            apt update;;
     * ) echo -e "${GREEN} The stable distribution will be used${END} \n" 1>&2 
            Sourcelists;;
   esac
   fw_scaleway="https://raw.githubusercontent.com/mathieuchot/Debian-startup/master/firewall-vps1.sh"
   fw_perso=""
   fw_server=""
   fw_router=""
   echo -e "${GREEN} Which firewall script do you want to use for this system ?${END} \n" 1>&2
   read -p " ${GREEN} vps | perso | server | router : ${END}" choice
   case "$choice" in 
     vps) wget -q $fw_scaleway -O /etc/init.d/firewall.sh ;;
     perso) wget -q $fw_perso -O /etc/init.d/firewall.sh ;;
     server) wget -q $fw_server -O /etc/init.d/firewall.sh ;;
     router) wget -q $fw_router -O /etc/init.d/firewall.sh ;;
     * ) #echo "${RED} Please choose one of the following options${GREEN} vps | perso | server | router : ${END}" 
         exit ;;
   esac
   if [[ $? -eq 0 ]]; then
      chmod +x /etc/init.d/firewall.sh 
      update-rc.d firewall.sh defaults
      if [[ $? -eq 0 ]]; then
         read -p " ${GREEN} Do you want to start the firewall now ? ${END}" choice
            case "$choice" in 
               Y|y) echo -e " ${GREEN}Starting the firewall...${END}" 
                    /etc/init.d/firewall.sh start ;;
               N|n) echo -e " ${GREEN}OK the firewall will start at the next reboot${END}";;
               *) echo -e " ${GREEN}Starting the firewall !${END}"
                  /etc/init.d/firewall.sh start ;; 
            esac
      else
         echo -e " ${RED} Couldn't make the script run at boot time.${END}"
      fi
   else
      echo -e " ${RED} An error has been encountered while downloading the firewall script.${END}"
   fi
}

Pkginstall(){
   echo -e "${BLUE}[2/5]${GREEN} Installing needed packages...  \n ${END}" 1>&2
   #"auditd" 
   declare -a listpkg=("git" "vim" "sudo" "logwatch" "build-essential" "dos2unix" "screen" "rsync" "htop" "strace" "python-dev" "python-pip" "tree" "open-vm-tools" "open-vm-tools-desktop" "pep8" "pylint" "tcpdump"  "ntpdate" "curl" "zip" "linux-headers-$(uname -r)" "unrar-free" "p7zip-full" "unzip" "macchanger" "irssi" "terminator" "fonts-inconsolata")
   apt-get update -y
   for pkg in "${listpkg[@]}"; do
      is_installed=$(dpkg-query -W -f='${Status}\n' "$pkg" | head -n1 | awk '{print $3;}')
      if [ "$is_installed" != 'installed' ]; then
            DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --force-yes --no-install-recommends --auto-remove "$pkg"
         if [ $? -ne 0 ]; then 
            echo -e "${MAGENTA}[PKG]${RED} failed to install the package $pkg. error code: $?  ${END} \n" 1>&2
         else
            echo -e "${MAGENTA}[PKG]${GREEN} $pkg is now installed ! ${END} \n" 1>&2
         fi
      fi
   done
   read -p " ${GREEN}Do you want to add a user to the sudoers file (y/n)?${END}" choice
      case "$choice" in 
         y|Y )  echo -e " \n ${GREEN}List of users: ${END} \n "
            cut -d: -f1 /etc/passwd
            read -p "${GREEN}username: ${END}" sudouser
            echo "$sudouser  ALL=(ALL:ALL) ALL" >> /etc/sudoers
            if [ $? -ne 0 ]; then
               echo -e "${MAGENTA}[UPGRADE]${RED} An error has been encountered. Error code: $? ${END} \n" 1>&2
            fi
            exit
            ;;
         *) exit;;
      esac
   #echo "$USER  ALL=(ALL:ALL) ALL" >> /etc/sudoers
}


Upgrade(){
   echo -e "${BLUE}[5/5]${GREEN} Upgrading the systems  \n ${END}" 1>&2
   
   read -p " ${GREEN}Do you want to upgrade the system to the latest version (y/n)?${END}" choice
   case "$choice" in 
     y|Y )  echo -e "${MAGENTA}[UPGRADE]${GREEN} system is upgrading... ${END} \n" 1>&2
            apt-get update -y && apt-get -y dist-upgrade
            if [ $? -ne 0 ]; then
               echo -e "${MAGENTA}[UPGRADE]${RED} An error has been encountered. Error code: $? ${END} \n" 1>&2
            fi
            ;;
     n|N )  apt-get update -y ;;
     * ) echo -e "${MAGENTA}[UPGRADE]${RED}\n invalid${END}";;
   esac
}

if [ -z "$1" ]; then
    echo "Usage:  ${0##*/} [-getfiles] [-upgrade] [-pkginstall] [] [ALL] ${END}"
else
   case "$1" in
      -pkginstall) Pkginstall;;
      -getfiles) DefaultFiles;;
      -upgrade) Upgrade;;
      -ALL) echo 'a';;
   esac
fi


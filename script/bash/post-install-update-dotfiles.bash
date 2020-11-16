#!/bin/bash -e
#
# Description:
#   Post install scripts.
#
# See:
# - Pop!_OS post install by Willi Mutschler: https://mutschler.eu/linux/install-guides/pop-os-post-install
#
#==

distid=$(echo $(lsb_release -si)-$(lsb_release -sc) | tr '[:upper:]' '[:lower:]')

if [[ "$distid" != 'pop-focal' ]];then
    echo "Wrong distid=$distid"
    echo ""
    lsb_release -a
    exit 1
fi

check_install_apt () {
    if [ -z "$1" ];then
	echo "ERROR: please give at least the command name."
	exit 1
    fi
    command_name="$1"
    if [ -n "$2" ];then
	package_name="$2"
    else
	package_name=$command_name
    fi
    command -v "$command_name" > /dev/null || sudo apt-get install -y "$package_name" && echo "$package_name ALREADY INSTALLED."
}
install_lsb-core () {
    #
    # In order to not have "No LSB modules are available" message when running lsb_release.
    #
    # See:
    # - https://blog.echosystem.fr/?d=2016/10/18/14/15/23-debian-no-lsb-modules-are-available
    #
    #--
    case "$distid" in
	pop-focal | ubuntu-focal)
	    isinst="$(apt list --installed lsb-core 2> /dev/null | grep installed)"
	    if [ -z "$isinst" ];then
		sudo apt-get install lsb-core
	    else
		echo "lsb-core is ALREADY INSTALLED"
	    fi
	    ;;
	*)
	    echo "$distid is not implemented in ${FUNCNAME[0]}. Skipping ..."
    esac
}

install_teams () {
    install_teams=0
    command -v teams > /dev/null || install_teams=1
    if [ $install_teams == 1 ];then
	wget https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.3.00.25560_amd64.deb
	sudo apt install ./teams_1.3.00.25560_amd64.deb
	rm teams_1.3.00.25560_amd64.deb
    else
	echo "teams ALREADY INSTALLED."
    fi
}

install_slack () {
    ## Slack
    if [ -z $(command -v slack) ];then
	wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.3.2-amd64.deb
	sudo apt install -y ./slack-desktop-4.3.2-amd64.deb
	rm -f slack-desktop-4.3.2-amd64.deb
    else
	echo "slack ALREADY INSTALLED."
    fi
}


# Database management
install_dbeaver () {
    if [ -z $(command -v dbeaver) ];then
	wget https://dbeaver.io/files/7.2.2/dbeaver-ce_7.2.2_amd64.deb
	sudo apt install ./dbeaver-ce_7.2.2_amd64.deb
	rm dbeaver-ce_7.2.2_amd64.deb
    else
	echo "dbeaver ALREADY INSTALLED."
    fi
}


# main
## lsb_release
install_lsb-core
## APT
check_install_apt evince
check_install_apt autossh
check_install_apt pandoc
check_install_apt lynx
check_install thunderbird
check_install_apt virtualbox
check_install_apt exiftool libimage-exiftool-perl
install_dbeaver
# communication
install_teams
install_slack



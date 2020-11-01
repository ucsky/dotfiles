#!/bin/bash -e
#
# Description:
#   Post install scripts for Pop!_OS 20.04 LTS (focal)
#
# See also:
# - Pop!_OS post install by Willi Mutschler: https://mutschler.eu/linux/install-guides/pop-os-post-install
#
#==
if [ $(lsb_release -si) != Pop ] && [ $(lsb_release -c ) != focal ];then
    echo "Wrong distribution"
    lsb_realease -a
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
	package_name=$comand_name
    fi
    command -v "$command_name" || sudo apt-get install -y "$package_name" && echo "$package_name already installed." 
}

install_teams () {
    install_teams=0
    command -v teams || install_teams=1
    if [ $install_teams == 1 ];then
	wget https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.3.00.25560_amd64.deb
	sudo apt install ./teams_1.3.00.25560_amd64.deb
	rm teams_1.3.00.25560_amd64.deb
    fi
}

install_slack () {
    ## Slack
    if [ -z $(command -v slack) ];then
	wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.3.2-amd64.deb
	sudo apt install -y ./slack-desktop-4.3.2-amd64.deb
	rm -f slack-desktop-4.3.2-amd64.deb
    fi
}


install_teams
install_slack

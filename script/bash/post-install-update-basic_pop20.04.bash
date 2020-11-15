#!/bin/bash -e
#
# Description:
#   Post install scripts for Pop!_OS 20.04 LTS (focal)
#
# See:
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
	package_name=$command_name
    fi
    command -v "$command_name" > /dev/null || sudo apt-get install -y "$package_name" && echo "$package_name already installed."
}

install_teams () {
    install_teams=0
    command -v teams > /dev/null || install_teams=1
    if [ $install_teams == 1 ];then
	wget https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.3.00.25560_amd64.deb
	sudo apt install ./teams_1.3.00.25560_amd64.deb
	rm teams_1.3.00.25560_amd64.deb
    else
	echo "teams already installed."
    fi
}

install_slack () {
    ## Slack
    if [ -z $(command -v slack) ];then
	wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.3.2-amd64.deb
	sudo apt install -y ./slack-desktop-4.3.2-amd64.deb
	rm -f slack-desktop-4.3.2-amd64.deb
    else
	echo "slack already installed."
    fi
}

adjust_charging_thresholds(){
    # Adjust charging thresholds for best logevity of lithium batteries.
    #
    # See:
    # - https://support.system76.com/articles/battery
    #
    charge_control_start_threshold=40
    charge_control_end_threshold=80
    cstart=$charge_control_start_threshold
    cend=$charge_control_end_threshold
    fstart=/sys/class/power_supply/BAT0/charge_control_start_threshold
    fend=/sys/class/power_supply/BAT0/charge_control_end_threshold
    cstart0=$(cat $fstart)
    cend0=$(cat $fend)
    if [ $cstart != $cstart0 ];then
	echo "Modify start threshold from $cstart0 to $cstart"
	sudo echo $cstart > $fstart
    fi
    if [ $cend != $cend0 ];then
	echo "Modify end threshold from $cend0 to $cend"
	sudo echo $cend > $fend
    fi
}

install_tlp(){
    # TLP: for increase battery life.
    #
    # See:
    # - https://support.system76.com/articles/battery
    #
    #--
    if [ -z $(command -v tlp) ];then
	sudo apt install tlp tlp-rdw --no-install-recommends
    else
	echo "tlp already installed."
    fi
}


# main
check_install_apt virtualbox
adjust_charging_thresholds
install_tlp
check_install_apt powertop
install_teams
install_slack

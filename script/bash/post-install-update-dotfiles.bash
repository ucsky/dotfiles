#!/bin/bash -e
#
# Description:
#   Post install script.
#
# See:
# - Pop!_OS post install by Willi Mutschler: https://mutschler.eu/linux/install-guides/pop-os-post-install
#
#==


distid=$(echo $(lsb_release -si)-$(lsb_release -sc) | tr '[:upper:]' '[:lower:]')

if \
    [ "$distid" != 'pop-focal' ] \
	&& \
	[ "$distid" != 'ubuntu-focal' ];then
    echo "Wrong distid=$distid"
    echo ""
    lsb_release -a
    exit 1
fi

if [ "$PIU_INFO" != 1 ];then
    echo ""
    echo "INFO: please use Post Install Update env variable PIU_FULL=1 for full install update."
    echo ""
    export PIU_INFO=1
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
check_install_apt_pkg () {

    if [ -z "$1" ];then
	echo "ERROR: please give at least the command name."
	exit 1
    fi

    pkg_name="$1"
    set +e
    isinst="$(apt list --installed ${pkg_name} 2> /dev/null | grep installed)"
    set -e
    if [ -z "$isinst" ];then
	sudo apt-get install -y $pkg_name
    else
	echo "$pkg_name is ALREADY INSTALLED"
    fi

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

######################################################
# main
######################################################
## lsb_release
install_lsb-core

## APT

### package name and command are the same
check_install_apt autossh
check_install_apt darktable # photo
check_install_apt digikam # photo
check_install_apt gthumb # photo
check_install_apt kphotoalbum # photo
check_install_apt pandoc
check_install_apt lynx
check_install_apt shotwell # photo
check_install_apt thunderbird
check_install_apt virtualbox

### command and package name are different
check_install_apt exiftool libimage-exiftool-perl
check_install_apt pip3 python3-pip
check_install_apt csvcut csvkit
check_install_apt chromium chromium-browser

### there is no command
check_install_apt_pkg texlive-latex-base
check_install_apt_pkg texlive-fonts-recommended
check_install_apt_pkg texlive-fonts-extra
check_install_apt_pkg texlive-latex-extra
check_install_apt_pkg texlive-full

# DB management software
install_dbeaver

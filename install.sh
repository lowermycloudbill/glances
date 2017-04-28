#!/usr/bin/env bash
#
# GlancesAutoInstall script
# Version: Glances 2.8
# Author:  Nicolas Hennion (aka) Nicolargo
#

# Execute a command as root (or sudo)
do_with_root() {
    # already root? "Just do it" (tm).
    if [[ `whoami` = 'root' ]]; then
        $*
    elif [[ -x /bin/sudo || -x /usr/bin/sudo ]]; then
        echo "sudo $*"
        sudo $*
    else
        echo "Glances requires root privileges to install."
        echo "Please run this script as root."
        exit 1
    fi
}

# Detect distribution name
if [[ `which lsb_release 2>/dev/null` ]]; then
    # lsb_release available
    distrib_name=`lsb_release -is`
else
    # lsb_release not available
    lsb_files=`find /etc -type f -maxdepth 1 \( ! -wholename /etc/os-release ! -wholename /etc/lsb-release -wholename /etc/\*release -o -wholename /etc/\*version \) 2> /dev/null`
    for file in $lsb_files; do
        if [[ $file =~ /etc/(.*)[-_] ]]; then
            distrib_name=${BASH_REMATCH[1]}
            break
        else
            echo "Sorry, GlancesAutoInstall script is not compliant with your system."
            echo "Please read: https://github.com/nicolargo/glances#installation"
            exit 1
        fi
    done
fi

echo "Detected system:" $distrib_name

shopt -s nocasematch
# Let's do the installation
if [[ $distrib_name == "ubuntu" || $distrib_name == "LinuxMint" || $distrib_name == "debian" || $distrib_name == "Raspbian" ]]; then
    # Ubuntu/Debian variants

    # Set non interactive mode
    set -eo pipefail
    export DEBIAN_FRONTEND=noninteractive

    # Make sure the package repository is up to date
    do_with_root apt-get -y --force-yes update

    # Install prerequirements
    do_with_root apt-get install -y --force-yes python-pip python-dev gcc lm-sensors wireless-tools

elif [[ $distrib_name == "redhat" || $distrib_name == "centos" || $distrib_name == "Scientific" ]]; then
    # Redhat/CentOS/SL

    # Install prerequirements
    do_with_root yum -y install python-pip python-devel gcc lm_sensors wireless-tools

elif [[ $distrib_name == "centminmod" ]]; then
    # /CentOS min based

    # Install prerequirements
    do_with_root yum -y install python-devel gcc lm_sensors wireless-tools
    do_with_root wget -O- https://bootstrap.pypa.io/get-pip.py | python && $(which pip) install -U pip && ln -s $(which pip) /usr/bin/pip

elif [[ $distrib_name == "fedora" ]]; then
    # Fedora

    # Install prerequirements
    do_with_root dnf -y install python-pip python-devel gcc lm_sensors wireless-tools

elif [[ $distrib_name == "arch" ]]; then
    # Arch support

    # Headers not needed for Arch, shipped with regular python packages
    do_with_root pacman -S python-pip lm_sensors wireless_tools --noconfirm

else
    # Unsupported system
    echo "Sorry, GlancesAutoInstall script is not compliant with your system."
    echo "Please read: https://github.com/nicolargo/glances#installation"
    exit 1

fi
shopt -u nocasematch

echo "Install dependancies"

# Glances issue #922: Do not install PySensors (SENSORS)
DEPS="setuptools"

# Install libs
do_with_root pip install --upgrade pip
do_with_root pip install $DEPS

CLOUDINFO_CONF_DIR="/etc/cloudinfo/"
CLOUDINFO_CONF_URL=""
GLANCES_DIR="glances-0.0.9"
GLANCES_TARBALL_NAME="glances-0.0.9.tar.gz"
GLANCES_TARBALL_URL="https://s3-us-west-2.amazonaws.com/lmcb-glances/$GLANCES_TARBALL_NAME"

do_with_root wget $GLANCES_TARBALL_URL -O /tmp/$GLANCES_TARBALL_NAME
do_with_root tar -xvf /tmp/$GLANCES_TARBALL_NAME
cd /tmp/$GLANCES_DIR
do_with_root python /tmp/$GLANCES_DIR/setup.py install
do_with_root mkdir -p $CLOUDINFO_CONF_DIR
#do_with_root wget $CLOUDINFO_CONF_URL -O $CLOUDINFO_CONF_DIR

# Install or ugrade Glances from the Pipy repository
#if [[ -x /usr/local/bin/glances || -x /usr/bin/glances ]]; then
#    echo "Upgrade Glances and dependancies"
#    # Upgrade libs
#    do_with_root pip install --upgrade $DEPS
#    do_with_root pip install --upgrade glances
#else
#    echo "Install Glances"
#    # Install Glances
#    do_with_root pip install glances
#fi
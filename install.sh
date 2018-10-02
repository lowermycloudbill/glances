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

APIKEY=$1
shopt -s nocasematch
# Let's do the installation
if [[ `apt-get 2>/dev/null` ]]; then
    # Ubuntu/Debian variants

    # Set non interactive mode
    set -eo pipefail
    export DEBIAN_FRONTEND=noninteractive

    # Make sure the package repository is up to date
    do_with_root apt-get -y --force-yes update

    # Install prerequirements
    do_with_root apt-get install -y --force-yes python-pip python-dev gcc lsb-release wget curl tar

elif [[ `dnf 2>/dev/null` ]]; then
    # Fedora

    # Install prerequirements
    do_with_root dnf -y install python-pip python-devel gcc wget curl tar --nogpgcheck
elif [[ `yum 2>/dev/null` ]]; then
    # Redhat/CentOS/SL

    # Install prerequirements
    do_with_root yum -y install wget python-devel python-setuptools gcc wget curl tar
    do_with_root easy_install pip
    do_with_root pip install -U pip setuptools

elif [[ `zypper 2>/dev/null` ]]; then
    # SuSE/openSuSE
    zypper --non-interactive in python-pip python-devel gcc python-curses wget curl tar python-setuptools gzip
elif [[ `pacman 2>/dev/null` ]]; then
    # Arch support

    # Headers not needed for Arch, shipped with regular python packages
    do_with_root pacman -S python-pip wget curl tar
else
    # Unsupported system
    echo "Sorry, GlancesAutoInstall script is not compliant with your system."
    echo "Please read: https://github.com/nicolargo/glances#installation"
    exit 1
fi
shopt -u nocasematch


CLOUDADMIN_FILE_NAME="cloudadmin.conf"
CLOUDADMIN_CONF_DIR="/etc/cloudadmin/"
CLOUDADMIN_CONF_URL="https://metrics.cloudadmin.io"
GLANCES_DIR="glances-0.3.3"
GLANCES_TARBALL_NAME="glances-0.3.3.tar.gz"
GLANCES_TARBALL_URL="https://s3-us-west-2.amazonaws.com/cloudadmin.io/$GLANCES_TARBALL_NAME"

SYSTEMD_FILE_NAME="glances.service"
SYSTEMD_DIRECTORY="/etc/systemd/system"

do_with_root wget $GLANCES_TARBALL_URL -O /tmp/$GLANCES_TARBALL_NAME
do_with_root tar -xvf /tmp/$GLANCES_TARBALL_NAME -C /tmp
cd /tmp/$GLANCES_DIR
do_with_root python /tmp/$GLANCES_DIR/setup.py install

#create conf directory for cloudadmin.conf
do_with_root mkdir -p $CLOUDADMIN_CONF_DIR

#dump the config
cat <<EOF > $CLOUDADMIN_CONF_DIR/$CLOUDADMIN_FILE_NAME
[CloudAdmin]
APIKey=$APIKEY
URL=$CLOUDADMIN_CONF_URL
EOF

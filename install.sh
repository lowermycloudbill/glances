#!/usr/bin/env bash
#
# GlancesAutoInstall script
# Version: Glances 2.8
# Author:  Nicolas Hennion (aka) Nicolargo
#
setup_service() {
cat > /etc/init.d/glances << 'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          Glances
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       CloudAdmin fork of Glances
### END INIT INFO

SCRIPT="TEST=1 /usr/local/bin/glances --quiet --export-http"
RUNAS=root

PIDFILE=/var/run/glances.pid
LOGFILE=/var/log/glances.log

start() {
  if [ -f /var/run/$PIDNAME ] && kill -0 $(cat /var/run/$PIDNAME); then
    echo 'Service already running' >&2
    return 1
  fi
  echo 'Starting service…' >&2
  local CMD="$SCRIPT &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD" $RUNAS > "$PIDFILE"
  echo 'Service started' >&2
}

stop() {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'Service not running' >&2
    return 1
  fi
  echo 'Stopping service…' >&2
  kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
  echo 'Service stopped' >&2
}

uninstall() {
  echo -n "Are you really sure you want to uninstall this service? That cannot be undone. [yes|No] "
  local SURE
  read SURE
  if [ "$SURE" = "yes" ]; then
    stop
    rm -f "$PIDFILE"
    echo "Notice: log file is not be removed: '$LOGFILE'" >&2
    update-rc.d -f <NAME> remove
    rm -fv "$0"
  fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  uninstall)
    uninstall
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|uninstall}"
esac
EOF

#Let's start this up!
chmod +x /etc/init.d/glances
update-rc.d -f glances remove
update-rc.d glances defaults
service glances start
}

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
GLANCES_LOCATION=/usr/local/bin/glances

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
    do_with_root dnf -y install python-pip python-devel gcc wget curl tar
elif [[ `yum 2>/dev/null` ]]; then
    # Redhat/CentOS/SL

    # Install prerequirements
    do_with_root yum -y install wget python-devel python-setuptools gcc wget curl tar
    do_with_root easy_install pip
    do_with_root pip install -U pip setuptools

    #Glances bin in different location
    GLANCES_LOCATION=/bin/glances
elif [[ `zypper 2>/dev/null` ]]; then
    # SuSE/openSuSE
    zypper --non-interactive in python-pip python-devel gcc python-curses wget curl tar
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


CLOUDADMIN_FILE_NAME="cloudadmin.conf"
CLOUDADMIN_CONF_DIR="/etc/cloudadmin/"
CLOUDADMIN_CONF_URL="https://metrics.cloudadmin.io"
GLANCES_DIR="glances-0.3.2"
GLANCES_TARBALL_NAME="glances-0.3.2.tar.gz"
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

UBUNTU_VERSION=`lsb_release -rs`

if [ "$UBUNTU_VERSION" == "12.04" ]
then
setup_service
fi

if [ "$UBUNTU_VERSION" == "14.04" ]
then
setup_service
fi

if [ "$UBUNTU_VERSION" == "16.04" ] ; then
cat <<EOF > $SYSTEMD_DIRECTORY/$SYSTEMD_FILE_NAME
[Unit]
Description=Glances

[Service]
ExecStart=TEST=1 $GLANCES_LOCATION --quiet --export-http
Restart=on-failure
RestartSec=30s
TimeoutSec=30s

[Install]
WantedBy=multi-user.target
EOF

#install and start the daemon!
do_with_root systemctl enable glances.service
do_with_root systemctl start glances.service &

fi

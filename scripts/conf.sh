#!/usr/bin/env bash
echo "Please Enter API Key:"
read APIKEY

mkdir -p /etc/lowermycloudbill/
DEMIDECODE=$(dmidecode -s bios-version)
INSTANCEID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
INSTANCETYPE=$(curl http://169.254.169.254/latest/meta-data/instance-type/)
AVAILABILITYZONE=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone/)

cat > /etc/lowermycloudbill/lowermycloudbill.conf <<EOL
[LowerMyCloudBill]
APIKey=${APIKEY}
URL=http://development-metrics.lowermycloudbill.com

[CloudProvider]
DemideCode=${DEMIDECODE}
InstanceID=${INSTANCEID}
InstanceType=${INSTANCETYPE}
AvailabilityZone=${AVAILABILITYZONE}
EOL

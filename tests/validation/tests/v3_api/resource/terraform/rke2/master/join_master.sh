#!/bin/bash
# This script is used to join one or more nodes as masters to the first master
set -x
echo $@
hostname=`hostname -f`
mkdir -p /etc/rancher/rke2
cat <<EOF >>/etc/rancher/rke2/config.yaml
write-kubeconfig-mode: "0644"
tls-san:
  - ${2}
server: https://${3}:9345
token:  "${4}"
cloud-provider-name:  "aws"
node-name: "${hostname}"
EOF

echo "$7"
if [[ ! -z "$7" ]] && [[ "$7" == *":"* ]]
then
   echo "$7"
   echo -e "$7" >> /etc/rancher/rke2/config.yaml
   cat /etc/rancher/rke2/config.yaml
fi

if [ ${1} = "rhel" ]
then
   subscription-manager register --auto-attach --username=${8} --password=${9}
   subscription-manager repos --enable=rhel-7-server-extras-rpms
fi

if [ ${6} = "rke2" ]
then
   curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${5} sh -
   sudo systemctl enable rke2-server
   sudo systemctl start rke2-server
else
   curl -sfL https://get.rancher.io | INSTALL_RANCHERD_VERSION=${5} sh -
   sudo systemctl enable rancherd-server
   sudo systemctl start rancherd-server
fi

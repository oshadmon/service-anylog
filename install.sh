#!/bin/bash

MONGO_IMAGE_TAG=4.0.6 >> ~/.bashrc
POSTGRES_IMAGE_TAG=16.0 >> ~/.bashrc
HZN_LISTEN_IP=172.235.53.13 >> ~/.bashrc
source ~/.bashrc

for cmd in update upgrade ; do
  sudo apt-get -y ${cmd}
done

curl -sSL https://raw.githubusercontent.com/open-horizon/devops/master/mgmt-hub/deploy-mgmt-hub.sh -A -R | bash
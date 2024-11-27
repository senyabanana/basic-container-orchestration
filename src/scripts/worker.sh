#!/bin/bash

sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update

sudo apt-get install -y docker-ce

sudo usermod -aG docker $USER

join_token=$(cat /vagrant/swarm_token.txt)

sudo docker swarm join --token $join_token 192.168.50.10:2377

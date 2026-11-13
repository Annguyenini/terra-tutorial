#!/bin/bash
apt-get update -y

apt-get install -y git

apt-get install -y docker

apt-get install -y nginx

systemctl enable docker
systemctl start docker

systemctl enable nginx
systemctl start nginx
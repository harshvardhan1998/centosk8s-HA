#!/bin/bash
host1=$1
host2=$2
host3=$3
proxy=$4
scp  prerequisite.sh  centos@$host1:/home/centos
ssh centos@$host1  chmod +x  /home/centos/prerequisite.sh
ssh centos@$host1 sudo su -c  /home/centos/prerequisite.sh root


scp  prerequisite.sh  centos@$host2:/home/centos
ssh centos@$host2  chmod +x   /home/centos/prerequisite.sh
ssh centos@$host2 sudo su -c  /home/centos/prerequisite.sh root

scp  prerequisite.sh  centos@$host3:/home/centos
ssh centos@$host3  chmod +x  /home/centos/prerequisite.sh
ssh centos@$host3 sudo su -c  /home/centos/prerequisite.sh root


ssh centos@$host1 sudo kubeadm init --control-plane-endpoint $proxy:6443 --upload-certs --pod-network-cidr=10.244.0.0/16 |  grep -m1  certificate-key > certificate
ssh centos@$host1 mkdir -p $HOME/.kube
ssh centos@$host1 sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
ssh centos@$host1 sudo chown $(id -u):$(id -g) $HOME/.kube/config
ssh centos@$host1 kubeadm token create --print-join-command | grep -m1 kubeadm > join-cmd
ssh centos@$host1 echo -n $(cat  join-cmd) >  join-cmd
ssh centos@$host1 cat /home/centos/centosk8s-HA/certificate >>  join-cmd




scp  join-cmd centos@$host2:/home/centos
ssh centos@$host2 chmod +x  join-cmd
ssh centos@$host2  sudo /home/centos/join-cmd
ssh centos@$host2 mkdir -p $HOME/.kube
ssh centos@$host2 sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
ssh centos@$host2 sudo chown $(id -u):$(id -g) $HOME/.kube/config


scp  join-cmd  centos@$host3:/home/centos
ssh centos@$host3 chmod +x  join-cmd
ssh centos@$host3  sudo /home/centos/join-cmd
ssh centos@$host3 mkdir -p $HOME/.kube
ssh centos@$host3 sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
ssh centos@$host3 sudo chown $(id -u):$(id -g) $HOME/.kube/config



ssh centos@$host1 kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml
ssh centos@$host1 kubectl taint nodes --all node-role.kubernetes.io/master-


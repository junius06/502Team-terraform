#!/bin/bash
systemctl restart sshd
hostnamectl set-hostname ec2-an2-mkkim-dev-mgmt-01a

# Kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.0/2024-09-12/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin

# Docker
sudo yum install docker -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# Helm - 동작 확인 필요
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh

# aws eks update-kubeconfig --region ap-northeast-2 --name dev-fmm-uw2-eks-svc-cluster-01

# source <(kubectl completion bash) 
# echo "source <(kubectl completion bash)" >> ~/.bashrc

# echo "alias k=kubectl" >> ~/.bashrc
# echo "complete -o default -F __start_kubectl k" >> ~/.bashrc
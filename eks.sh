#!/bin/bash

# Update package lists
sudo yum update -y

# Install wget if not present
if ! command -v wget &> /dev/null; then
    sudo yum install -y wget
fi

# Install curl if not present
if ! command -v curl &> /dev/null; then
    sudo yum install -y curl
fi

# Install git if not present
if ! command -v git &> /dev/null; then
    sudo yum install -y git
fi

# Install kubectl for amd64 architecture (x86_64)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256) kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl kubectl.sha256

# Install kubectx and kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install AWS CLI v2 for amd64 architecture
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# Verify installations
echo "Verifying installations..."
kubectl version --client
kubectx --help
kubens --help
aws --version
wget --version

echo "Installation complete!"

# Add autocompletion for kubectl
echo 'source <(kubectl completion bash)' >>~/.bashrc

# Add autocompletion for kubectx and kubens
echo 'source /opt/kubectx/completion/kubectx.bash' >>~/.bashrc
echo 'source /opt/kubectx/completion/kubens.bash' >>~/.bashrc

# Reload bash configuration
source ~/.bashrc

#AWS Configure

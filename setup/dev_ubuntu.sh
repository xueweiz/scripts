set -euxo pipefail

# passwordless sudo
sudo grep "ALL   ALL = (ALL) NOPASSWD: ALL" /etc/sudoers || echo "ALL   ALL = (ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# browser
sudo apt update
# Do NOT install chromium-browser. It is based on snap, and has a
# problem accessing /tmp:
# https://bugs.launchpad.net/ubuntu/+source/chromium-browser/+bug/1851250
# sudo apt install -y chromium-browser
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo dpkg -l | grep firefox | awk '{print $2}' | xargs sudo dpkg --remove --force-remove-reinstreq

# commandline utils
sudo apt install -y git vim terminator
git config --global user.email "kentxuewei@gmail.com"
git config --global user.name "Xuewei Zhang"

# sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt install -y apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update
sudo apt install -y sublime-text sublime-merge

# go
sudo apt install -y curl binutils bison gcc make
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source $HOME/.gvm/scripts/gvm
gvm install go1.4 -B
gvm use go1.4
export GOROOT_BOOTSTRAP=$GOROOT
gvm install go1.11
gvm use go1.11 --default

# k8s projects
cd $GOPATH
go get k8s.io/node-problem-detector
go get k8s.io/kubernetes
go get k8s.io/test-infra

# monitoring utils
sudo apt install -y iotop htop

# SSH key
ssh-keygen -t rsa -N '' -q -f ~/.ssh/id_rsa

# gcloud
curl https://sdk.cloud.google.com > /tmp/install.sh
bash /tmp/install.sh --disable-prompts
echo "export PATH=~/google-cloud-sdk/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc

# docker
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker xuewei
sudo usermod -aG docker root
newgrp docker

## interactive

# github auth
cat ~/.ssh/id_rsa.pub
read  -n 1 -p "Paste public key to https://github.com/settings/keys and press ENTER:"

# xueweiz repos
mkdir ~/zxw/
cd ~/zxw/
git clone git@github.com:xueweiz/scripts.git
git clone git@github.com:xueweiz/sos.git
git clone git@github.com:xueweiz/xueweiz.git

# npd
cd $GOPATH/src/k8s.io/node-problem-detector
git remote add xueweiz git@github.com:xueweiz/node-problem-detector.git
git pull xueweiz

# debug
sudo apt install -y linux-tools-common
sudo apt install -y linux-tools-5.4.0-28-generic

# bpf
sudo apt install -y build-essential make libelf-dev clang strace tar bpfcc-tools linux-headers-$(uname -r) gcc-multilib

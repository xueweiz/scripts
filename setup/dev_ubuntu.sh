#!/usr/bin/env bash

# echo "HandleLidSwitch=ignore" | sudo tee /etc/systemd/logind.conf

set -euxo pipefail

function basic-upgrade() {
	sudo apt update
	sudo apt upgrade -y
}

function setup-linux() {
	# common
	sudo apt install -y git vim terminator iotop htop sysstat
	# kernel tools
	sudo apt install -y linux-tools-common linux-tools-$(uname -r)
	# bpf tools
	sudo apt install -y build-essential make libelf-dev clang strace tar bpfcc-tools linux-headers-$(uname -r) gcc-multilib
}

function setup-sudo() {
	set +e
	sudo grep -q "ALL   ALL = (ALL) NOPASSWD: ALL" /etc/sudoers
	if [ $? -ne 0 ]; then
		echo "ALL   ALL = (ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
	fi
	set -e
}

function setup-browser() {
	# Do NOT install chromium-browser. It is based on snap, and has a
	# problem accessing /tmp:
	# https://bugs.launchpad.net/ubuntu/+source/chromium-browser/+bug/1851250
	# sudo apt install -y chromium-browser
	dpkg-query -W google-chrome-stable && return 0 || true
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo dpkg -i google-chrome-stable_current_amd64.deb
	dpkg -l | grep firefox | awk '{print $2}' | xargs sudo dpkg --remove --force-remove-reinstreq
}

function setup-editor() {
	dpkg-query -W sublime-text && return 0 || true
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
	sudo apt install -y apt-transport-https
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	sudo apt update
	sudo apt install -y sublime-text sublime-merge
}

function setup-go() {
	which go && return 0 || true
	sudo apt install -y curl binutils bison gcc make
	set +u
	bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
	source ~/.gvm/scripts/gvm
	gvm install go1.4 -B
	gvm use go1.4 --default
	export GOROOT_BOOTSTRAP=$GOROOT
	gvm install go1.11
	gvm use go1.11 --default
	set -u
}

function setup-repo() {
	# k8s projects
	pushd $GOPATH
	go get k8s.io/node-problem-detector || true
	go get k8s.io/kubernetes || true
	go get k8s.io/test-infra || true
	popd
	# xueweiz github repo
	mkdir ~/zxw/ || true
	pushd ~/zxw/
	git clone git@github.com:xueweiz/scripts.git || true
	git clone git@github.com:xueweiz/sos.git || true
	git clone git@github.com:xueweiz/xueweiz.git || true
	popd
	# npd
	pushd $GOPATH/src/k8s.io/node-problem-detector
	git remote add xueweiz git@github.com:xueweiz/node-problem-detector.git || true
	git fetch xueweiz
	popd
	# linux
	pushd ~/zxw/
	git clone git@github.com:xueweiz/linux.git --depth 1
	pushd linux
	git remote add linus https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
	git remote add stable https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/
	popd
	popd
}

function setup-gcloud() {
	which gcloud && return 0 || true
	curl https://sdk.cloud.google.com > /tmp/install.sh
	bash /tmp/install.sh --disable-prompts
	echo "export PATH=~/google-cloud-sdk/bin:\$PATH" >> ~/.bashrc
	source ~/.bashrc
}

function setup-docker() {
	which docker && return 0 || true
	sudo apt install -y docker.io
	sudo systemctl enable --now docker
	sudo usermod -aG docker $USER
	sudo usermod -aG docker root
}

function setup-creds() {
	# SSH key
	if [ ! -f ~/.ssh/id_rsa ]; then
		ssh-keygen -t rsa -N '' -q -f ~/.ssh/id_rsa
	fi
	# github
	cat ~/.ssh/id_rsa.pub
	read -n 1 -p "Paste public key to https://github.com/settings/keys and press ENTER:"
}

function setup-personal() {
	# git
	git config --global user.email "kentxuewei@gmail.com"
	git config --global user.name "Xuewei Zhang"
	git config --global core.editor "vim"
	# sublime
	pushd ~/zxw/scripts/setup/subl/
	./restore.sh
	popd
}

function setup-ubuntu-desktop() {
	# https://askubuntu.com/questions/1230924/ubuntu-20-04-does-not-recognize-second-monitor
	dpkg-query -W nvidia-driver-435 && return 0 || true
	sudo apt install nvidia-driver-435
	# disable remote printing to speed up shutdown
	sudo systemctl disable cups-browsed.service || true
}

function main() {
	cd /tmp
	basic-upgrade
	
	setup-sudo
	setup-browser
	setup-editor
	setup-linux

	setup-go
	setup-gcloud

	setup-ubuntu-desktop

	# interactive
	setup-personal
	setup-creds
	setup-repo
}

main "${@}"

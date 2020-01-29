# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Box / OS
VAGRANT_BOX = "bento/ubuntu-18.04"
VAGRANT_BOX_VERSION = "201912.14.0"
# Memorable name for your vm
VM_NAME = 'Wellcelar'
# Host folder to sync
HOST_PATH = Dir.pwd
# Where to sync to on Guest — 'vagrant' is the default user name
GUEST_PATH = '/home/vagrant/Wellclear'
# # VM Port — uncomment this to use NAT instead of DHCP
# VM_PORT = 8080
Vagrant.configure(2) do |config|
  # Vagrant box from Hashicorp
  config.vm.box = VAGRANT_BOX
  config.vm.box_version = VAGRANT_BOX_VERSION
  # setup x11 forwarding
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true
  # Actual machine name
  config.vm.hostname = VM_NAME
  # Set VM name in Virtualbox
  config.vm.provider "virtualbox" do |v|
    v.name = VM_NAME
    v.memory = 8192
    v.cpus = 4
  end
  # DHCP — comment this out if planning on using NAT instead
  config.vm.network "private_network", type: "dhcp"
  # Port forwarding — uncomment this to use NAT instead of DHCP
  # config.vm.network "forwarded_port", guest: 80, host: VM_PORT
  # Sync folder
  config.vm.synced_folder HOST_PATH, GUEST_PATH
  # Disable default Vagrant folder, use a unique path per project
  config.vm.synced_folder '.', '/home/vagrant', disabled: true
  # Install needed development tools
  config.vm.provision "shell", inline: <<-SHELL

    make_dir () {
      if [ ! -d $1 ]; then
        mkdir $1
      fi
    }
    make_dir /home/vagrant/Downloads
    make_dir /home/vagrant/Documents
    sudo apt-get update
    sudo dpkg --configure -a

  SHELL
end
Vagrant.configure("2") do |config|

  config.vm.box = "debian/buster64"
  config.vm.disk :disk, size: "70GB", primary: true
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "LFS"
  end

  config.vm.provision :ansible do |ansible|
    ansible.playbook = "playbook.yml"
  end

end

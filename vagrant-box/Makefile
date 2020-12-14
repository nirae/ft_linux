.PHONY: build add remove test clean

build:
	packer build packer.json

add:
	vagrant box add ft_linux ft_linux-amd64-virtualbox.box

remove:
	vagrant box remove ft_linux --all

test:
	mkdir -p vm
	cd vm && vagrant init ft_linux && vagrant up

clean: remove
	rm -rf ft_linux-amd64-virtualbox.box
	cd vm && vagrant destroy -f
	rm -rf vm

vagrant-setup:
	export VAGRANT_EXPERIMENTAL="disks"

ansible-setup:
	ansible-galaxy collection install community.general
	ansible-galaxy collection install ansible.posix

up:
	VAGRANT_EXPERIMENTAL="disks" vagrant up

download-packages:
	mkdir -p packages-sources
	wget --input-file=wget-list --continue --directory-prefix=packages-sources

download-bonus-packages:
	mkdir -p packages-sources
	wget --input-file=wget-bonus-list --continue --directory-prefix=packages-sources

lfs-ssh:
	sshpass -p 'lfs' ssh lfs@localhost -p 2222

ssh:
	sshpass -p 'toor' ssh root@localhost -p 2222

scp-correction:
	sshpass -p 'toor' scp -P 2222 correction_scripts/* root@localhost:/root

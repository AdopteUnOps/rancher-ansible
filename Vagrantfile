Vagrant.configure("2") do |config|
  config.vm.define "rancher-master" do |ranchermaster|
    ranchermaster.vm.box = "ubuntu/xenial64"
    ranchermaster.vm.network "private_network", ip: "192.168.100.10", virtualbox__intnet: true
    ranchermaster.vm.hostname = "rancher-master.demo"
  end 

  config.vm.define "rancher-host1" do |rancherhost1|
    rancherhost1.vm.box = "ubuntu/xenial64"
    rancherhost1.vm.network "private_network", ip: "192.168.100.20", virtualbox__intnet: true
    rancherhost1.vm.hostname = "rancher-host1.demo"
  end 

  config.vm.provision "configure-host", type:'ansible' do |ansible|
    ansible.config_file = 'ansible.cfg'
    ansible.limit = "all" 
    ansible.playbook = 'configure_host.yml'
    ansible.raw_arguments = ["-e NAME_PROJECT=all"]
  end
end

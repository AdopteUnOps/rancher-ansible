Vagrant.configure("2") do |config|
  config.vm.define "rancher-master" do |ranchermaster|
    ranchermaster.vm.box = "ubuntu/xenial64"
    ranchermaster.vm.network "private_network", ip: "192.168.100.10", virtualbox__intnet: true
    ranchermaster.vm.hostname = "rancher-master.demo"
    #ranchermaster.vm.provider "virtualbox" do |vb|
    #  dockerDisk = '.vagrant/machines/rancher-master/dockerDisk.vdi'
    #  if not File.exists?(dockerDisk)
    #    vb.customize ['createhd', '--filename', dockerDisk, '--variant', 'Fixed', '--size', 10 * 1024 ]
    #  end
    #  vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', dockerDisk]
    #end
  end 

  config.vm.define "rancher-host1" do |rancherhost1|
    rancherhost1.vm.box = "ubuntu/xenial64"
    rancherhost1.vm.network "private_network", ip: "192.168.100.20", virtualbox__intnet: true
    rancherhost1.vm.hostname = "rancher-host1.demo"
    #rancherhost1.vm.provider "virtualbox" do |vb|
    #  dockerDisk = '.vagrant/machines/rancher-host1/dockerDisk.vdi'
    #  if not File.exists?(dockerDisk)
    #    vb.customize ['createhd', '--filename', dockerDisk, '--variant', 'Fixed', '--size', 10 * 1024]
    #  end
    #  vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', dockerDisk]
    #end
  end 

  config.vm.provision "configure-host", type:'ansible' do |ansible|
    ansible.config_file = 'ansible.cfg'
    ansible.limit = "all" 
    ansible.playbook = 'configure_host.yml'
    ansible.raw_arguments = ["-e NAME_PROJECT=all -e use_docker_lvm=false"]

  end

  config.vm.provision "install-rancher-master", type:'ansible' do |ansible|
    ansible.config_file = 'ansible.cfg'
    ansible.limit = "all" 
    ansible.playbook = 'create_master.yml'
    ansible.host_vars = {
      "rancher-master" => {
        "mysql_host" => "10.0.2.15",
        "mysql_database" => "rancher",
        "mysql_user" => "rancher",
        "mysql_password" => "rancher",
        "mysql_backup_enabled" => "false",
        "DEVOPS_LOGIN" => "devops",
        "DEVOPS_PASSWORD" => "changeme",
        "RANCHER_MASTER_URL" => "rancher-master",
        "RANCHER_MASTER_PORT" => "8080",
        "rancher_version" => "v1.6.10",
        "rancher_agent_version" => "1.2.6",
        "rancher_catalogs" => "[]"

      },
 
    }


    #ansible.raw_arguments = ["-e NAME_PROJECT=all -e ansible_inventory_dir=vagrant_demo"]
  end  
end

Vagrant.configure("2") do |config|
  #note that global provisionners will be run FIRST as they are less precise,
  #this is where we will trigger configure-host and then on a per host basis we will setup rancher master or a rancher host
  config.vm.define "rancher-master1" do |ranchermaster|
    ranchermaster.vm.box = "ubuntu/xenial64"
    ranchermaster.vm.network "private_network", ip: "192.168.100.10", virtualbox__intnet: true
    ranchermaster.vm.network "forwarded_port", guest: 8080, host: 8080
    ranchermaster.vm.hostname = "rancher-master1"
    ranchermaster.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
    end
    ranchermaster.vm.provision "install-rancher-master", type:'ansible' do |ansible|
      ansible.config_file = 'ansible.cfg'
      ansible.limit = "all"
      ansible.playbook = 'create_master.yml'
      ansible.groups = {
        "rancher-master" => [ "rancher-master1" ],
        "rancher-master:vars" => {
          "mysql_host" => "192.168.100.10",
          "mysql_database" => "rancher",
          "mysql_user" => "rancher",
          "mysql_password" => "rancher",
          "rancher_master_host" => "192.168.100.10",
          "rancher_master_port" => "8080",
        },

      }
    end
  end

  config.vm.define "rancher-host1" do |rancherhost|
    rancherhost.vm.box = "ubuntu/xenial64"
    rancherhost.vm.network "private_network", ip: "192.168.100.20", virtualbox__intnet: true
    rancherhost.vm.hostname = "rancher-host1"
    rancherhost.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
    end
    config.vm.provision "create-demo-project", type:'ansible' do |ansible|
      ansible.config_file = 'ansible.cfg'
      ansible.limit = "all"
      ansible.playbook = 'create_project.yml'
      ansible.groups = {
        "demo-project" => [ "rancher-host1"],
        "demo-project:vars" => {
          "rancher_master_host" => "192.168.100.10",
          "rancher_master_port" => "8080",
          "rancher_master_url" => "http://{{rancher_master_host}}:{{rancher_master_port}}",
          "rancher_project_name" => "{{NAME_PROJECT | lower }}"
        }
      }
      ansible.raw_arguments = ["-e NAME_PROJECT=demo-project"]
    end
  end

  config.vm.provision "configure-host", type:'ansible' do |ansible|
    ansible.config_file = 'ansible.cfg'
    ansible.limit = "all"
    ansible.playbook = 'configure_host.yml'
    ansible.raw_arguments = ["-e NAME_PROJECT=all -e use_docker_lvm=false"]
  end

end

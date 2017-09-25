# Project ansible to manage Rancher

## Foreword

If you don't know yet rancher please read the official documentation http://docs.rancher.com/rancher/latest/en/.

Rancher will be used to create segregated environments for projects.

Each project/environments should exists as "environments" in rancher (example: my-uat-project my-production-project ).
Each rancher environment is segregated at network level via Docker Overlay and IPSec tunnels (managed by rancher itself).

Only trusted ops can connect to the machines, unix accounts are managed by ansible.

Developpers will not be allowed to access rancher by itself, rancher master will be accessible only for ops for the moment.
End users will have tools in their project to see their application logs & metrics (elk, prometheus).

### Machine requirements

At the moment this set of playbooks is designed to be run on ubuntu. We recommend using latest LTS (16.04 at times of writing).

Each host (including the master) must have at least the following requirements :
* 2 vcpu
* 4 Go ram
* 2 disks with one for the system with 12Go (8Go for / + 4Go for swap) and one for /var/lib/docker with 8Go.

Note that by default we will only install docker on the machine, so the root filesystem doesn't needs to be big (just system logs and the base packages).
Docker will have it's own partition and everything will run inside containers, so if at some point you need more space you need to extends docker partition (see above)

### Exemple for test environments

2 hosts per rancher environment :
* one for tools (elk, prometheus, janitor) and the load balancer
* one for project

Ideally we should provide a secured jenkins for the project with a sample of pipeline to deploy across all environments.
The machine for tools will be identified with specific label on it (role=tools).

## Playbooks documentation

### Requirements

* Ansible >= 2.3

### Rancher platforms

Each rancher platform will have it's own configuration (inventory + group_vars + hosts_vars).
By default wrappers will use production one.

But you can use other ones changing inventory from the command line (everything is relative to the path of the inventory file).
```
./ansible-playbook_wrapper configure_host.yml -K -i path/to/inventory

```

### SSH configuration

Copy the file `config_ssh.template` to `config_ssh` in this local folder
then edit `config_ssh` to configure it. The user must match a user declared
in ssh_users list in `<rancher_cluster_name>/group_vars/all/vars`

To prevent typing sudo password when using ansible, create for each cluster
the file `<rancher_cluster_name>/group_vars/all/private` with the following content:

```
ansible_sudo_pass: your_sudo_password
```

Where your_sudo_password is the password declared in ssh_users list in `<rancher_cluster_name>/group_vars/all/vars`

Please note that if you are using this mechanism, it will always be used, even if you are using `-k` or `-K`

### Vault

Please add the vault password in `rancher/ansible/.ansible_vault_pass`

### Workflow to setup rancher from scratch

* run configure_host playbook
* run create_master playbook
* run create_project playbook (everytime you need to setup a new env)

### Configure the Machine
Use the configure_host.yml

You can bootstrap the machine for the first time with the following command

``` /ansible-playbook_wrapper configure_host.yml -u genericaccount -Kk ```

This ansible install

* Python
* Docker
* Create local user with ssh_key, put into the group ADM,SUDO and set the password
* Set machine hostname
* Configure ssh (disable root login, enforce auth by key)
* Remove the former ops account

All the next time you must launch

``` /ansible-playbook_wrapper configure_host.yml -K ```

Docker will be installed in /var/lib/docker folder with a lvm partition by default it will create it on /dev/sdb but you can configure it in you inventory file by overriding docker_disks variable.
```
mymachine docker_disks="/dev/sdb,/dev/sdc"
```

Note that the playbook will auto extends to 100% of the volume group the /var/lib/docker. So if in future you're out of space on docker partition just override that property and rerun the playbook.

###  Create a Master

Create a tag for the new Master, for example
```
[rancher-masters]
host-1
```

Configure the create_master.yml for [rancher-masters]

Launch the playbook
```
./ansible-playbook_wrapper create_master.yml -K
```

This playbook will create a file apiKey in {{ inventory_dir }}/group_vars/all/apikey. This file contains the RANCHER_API_KEY_ACCOUNT_TOKEN and RANCHER_API_KEY_ACCOUNT_SECRET

### Create a project

Create a tag for your project into the inventory for example
```
[my-first-rancher-project]
host-2
host-3
```

The first host of the tag will become the "tools" host (running elk, etc...).

Launch the playbook
```
./ansible-playbook_wrapper create_project.yml -K -e "NAME_PROJECT=my-first-rancher-project"
```

This ansible create :

* A project into RANCHER
* Create "API KEY ENVIRONMENT" into rancher and write into group_vars/{{NAME_PROJECT}}
* Add Host into the project
* Install some stacks : Janitor


### Utils clean project

To delete all hosts in a project run the playbook utils_add_registry.yml
```
./ansible-playbook_wrapper utils_clean_host.yml -K -e "NAME_PROJECT=myproject"
```

To delete one host in a project run the following command
```
./ansible-playbook_wrapper utils_clean_host.yml -K -e "NAME_PROJECT=myproject" -e "NAME_HOST=myHost
```

## Deployments

Deployments will be performed to developers via jenkins.
We will provide to dev teams a jenkins instance for their projects with a sample of deployment pipeline.
Our jenkins instance will have rancher-compose installed and a few utils scripts to simplify deployment.

rancher-compose will require an apikey per project.

Pipeline sample
```
withEnv(['RANCHER_COMPOSE_HOME=/usr/lib/rancher-compose', 'RANCHER_URL=http://rancher-master:8080/','RANCHER_SECRET_KEY=ABCD','RANCHER_ACCESS_KEY=ABCD']) {
    node {
       stage 'Prepare deploy'
       git credentialsId: 'projectname', url: 'git@your-git-repo'
       stage 'Deploy to UAT'
       sh '${RANCHER_COMPOSE_HOME}/deploy-stack.sh your-repo-git/deploy'
    }
    stage 'Validation'
    try {
        input message: 'UAT valid ?', ok: 'Yes please deploy to prod !'
    } catch (InterruptedException e) {
        node {
            sh '${RANCHER_COMPOSE_HOME}/rollback-stack.sh your-repo-git/deploy'
        }
        throw e
    }
    node {
       stage 'Deploy to Prod'
       sh '${RANCHER_COMPOSE_HOME}/confirm-deploy-stack.sh your-repo-git/deploy'
    }
    stage 'Validation in production'
    input message: 'Production OK ?', ok: 'Yes'

}
```

## Rancher catalog

Rancher offer a capability to write our own catalog (stacks ready to use). This can be useful if we want to provide some stuff for projects (exemple : mongodb + mongo ui + backups)
To create a catalog you just need to have a git repository with a templates folder containing a simple structure with docker-compose and rancher-compose files.

To register a catalog go to rancher-ui and go to admin/settings and add your catalog in the related section. The url should be something like https://user:token@your-git-repo.git

For more documentation on this topic check http://docs.rancher.com/rancher/latest/en/catalog/

To see our current catalog check https://github.com/AdopteUnOps/rancher-catalog

## Disaster recovery

If for some reason the host running rancher-master dies, application will remain up and running, so there is no impact.
If after running troubleshooting steps you don't have any clue we recommend you to wipe the master machine spawn a new master with "create_master.yml" playbook and run mysql restore script (see above).


### Quick cleanup procedure (optional)
This step can be skipped if you spawn a new master.

Run the following commands on your rancher-master
```
sudo service docker stop
rm -rf /var/lib/docker/*
rm -rf /var/lib/mysql/*
sudo service docker start
```

### Make sure master is configured properly
```
./ansible-playbook_wrapper create_master.yml -K
```

### Restore mysql

On the master enter into the container itself and run the restore script
```
sudo docker exec -ti mysql-backup-s3 bash
./restore.sh
```

This will restore the latest backup find on s3.

If you want to restore a specific backup you can do
```
ID_BUCKET_RESTORE=2016-07-21T133544Z.dump.sql.gz ./restore.sh
```

## Upgrading rancher

To upgrade rancher you just need to change the rancher_version version in group vars.
Exemple: in production/group_vars/all/vars
```
rancher_version: v1.1.1
```

We highly recommend to stick to a specific version for production rancher environment to make sure everything is repeatable.

Then just run again the create_master.yml playbook.
It will upgrade rancher-master smoothly.
When rancher-master is up again it will contact environments host agents and update it if necessary, this operation is done by rancher itself.

## Upgrading docker

To update docker you just need to set the docker_version variable.
If you want to set this version to all rancher platforms, just update it in roles/docker/defaults/main.yml.
If you want to set this version only for a particular rancher platform, add this variable in your group_vars/all/vars file.

Then run again the configure_host.yml playbook. Note that you will get downtime if your application containers are not resilient as docker will be restarted.

### Docker version caveats

WARNING: At the moment we use docker 1.10.3 which is not available for ubuntu-xenial.
This was required to deploy gluster fs with convoy as there is a bug right now on docker 1.11 see https://github.com/rancher/rancher/issues/4411

The docker version is currently configured in roles/docker/defaults/main.yml and we force the distribution name to wily to have access to the docker repository containing 1.10.3.
To make sure ansible does try to discover ubuntu version on hosts itself we have disabled gather_facts in configure_host.yml:
```
- hosts: all
  #remove this when the glusterfs bug will be fixed
  gather_facts: no
```

We highly recommend to upgrade to docker 1.11 or higher (if supported by rancher) when this bug will be fixed.

# Troubleshooting


To get live logs of a container (for example a crash looping one) you need to execute the following command on the docker host itself
```
docker logs --tail=1 -f DOCKERID
```

To get into a container  you need to execute the following command on the docker host itself
```
docker exec -ti DOCKERID bash
```

# If Docker daemon doesn't start

Check docker state
```
sudo service docker status
```

Check docker daemon logs
```
journalctl -u docker
```

If you get the following error it means you're missing aufs module in the kernel
```
30.117934755Z" level=error msg="[graphdriver] prior storage driver \"aufs\" failed: driver not supported"
```
In that case you should run again configure_host.yml on your host.

```
./ansible-playbook_wrapper configure_host.yml -e NAME_PROJECT=XXXX -l YOURHOSTNAME
```


### On master side

Check host global heatlh (freespace, memory, cpu).

Check docker state
```
sudo service docker status
```

Check docker daemon logs
```
journalctl -u docker
```

Check system logs
```
dmesg
```

Check the logs of rancherServer container.
```
sudo docker logs --tail=1000 -f rancherServer
```

### On environments hosts

Check container logs, if it doesn't work check the log of network agent container.

Check host global heatlh (freespace, memory, cpu).

Check docker state
```
sudo service docker status
```

Check docker daemon logs
```
journalctl -u docker
```

Check system logs
```
dmesg
```

This script allows you to store MySQL data files into RAM disk

Files will be synchronized automatically on startup and shutdown

How to install:
1. Login to your Rapberry Pi board by ssh and run next commands:
```
cd /mnt/data/docker-majordomo/
docker-compose down
sudo mv ./data/mysq ./data/mysql-real
sudo ln -s /mnt/data/docker-majordomo/scripts/mysql-tmpfs/ramdisk /etc/init.d/ramdisk 
sudo update-rc.d ramdisk default
```

2. Add next string in the end of /etc/fstab (`sudo vim /etc/fstab`)

`tmpfs /mnt/data/docker-majordomo/data/mysql tmpfs size=512m 0 0`

3. Add next job in the end of crontab (`sudo vim /etc/crontab`)

`*/10 * * * * root        /etc/init.d/ramdisk sync >> /dev/null 2>&1`
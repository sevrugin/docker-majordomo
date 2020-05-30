# docker-majordomo

***tested on Raspbian buster (Release date: 2020-05-27)
https://www.raspberrypi.org/downloads/

Make `ssh` login to your Raspberry PI, and go to steps:

Step0:

Install Docker

```
sudo apt install -y libffi-dev libssl-dev python python-pip mc build-essential git
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker pi
sudo reboot
sudo pip3 install docker-compose
sudo reboot
```

Step1: 

```
sudo mkdir /mnt/data
sudo chown pi:pi /mnt/data/
cd /mnt/data
git clone https://github.com/sevrugin/docker-majordomo.git
cd docker-majordomo
```
copy deffault config and make changes
```
cp .env.example .env && nano .env
sudo make clean
make init-all
```
All modules will be configured automatically

Also you can use `make init-app` and `make init-db` to init modules separately

Step 2: (or `-d` to start as daemon)

At first time you should use use `--build` parameter

```
docker-compose up --build -d
```
Rest of the time
```
docker-compose up -d
```

wait 20+ minutes

Step 3:

a) For initial setup "majordomo" follow http://your-ip-address/popup/first_start.html

- go to Control pannel -> Check updates -> Advance config and set to Alfa (latest updates) and reboot rpi/docker containers
- update majordomo from control panel and reboot rpi/docker containers
- install MQTT plugin (Control pannel -> Plugin market), and set to:
	
```
Hostname: 127.0.0.1
Subscription path: $SYS/broker/uptime, homebridge/from/#
```

b) For initial setup "phpmyadmin" follow http://your-ip-address:8081

c) For initial setup "homebridge" follow http://your-ip-address:8080

- Homebridge part (Login: Admin, Password: Admin):
	- Go to Homebridge Settings and turn on Homebridge Insecure Mode / Enable Accessory Control
	- install Homebridge Mqtt plugin (https://github.com/cflurin/homebridge-mqtt)
	- add to Homebridge configuration next block:
```
{
"platform": "mqtt",
"name": "mqtt",
"url": "mqtt://127.0.0.1",
"topic_type": "multiple",
"topic_prefix": "homebridge",
"username": "YOUR_USERNAME",
"password": "YOUR_PASSWORD"
}
```
- Majordomo part:

	- install HomeKit plugin (Control pannel -> Plugin market)
	- follow it and push Enable service
	- follow Objects -> HomeBridgeClass -> Edit -> Methods -> Add new method, and set to:
```
Title: dataUpdated
Code: require(DIR_MODULES.'devices/processHomebridgeMQTT.inc.php');
```

- follow Objects -> HomeBridgeClass -> Edit -> Properties, and set to all titles:

```
On-change Method -> dataUpdated
```

### Additional improvements

#### Working with MySQL data from the ramdisk

You are able to move you MySQL data into the RAM disk. This option make your system faster but will use near 200Mb of memory.

https://github.com/sevrugin/docker-majordomo/tree/master/scripts/mysql-tmpfs

### Optional - enable Pi4 64-bit raspbian kernel and update bootloader

add to config.txt

```
sudo nano /boot/config.txt
```

and add to the end:

```
arm_64bit=1
```

then update rpi and reboot:

```
sudo rpi-update
sudo reboot
```

test

```
uname -a
```

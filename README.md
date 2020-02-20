# docker-majordomo

***tested on Raspbian buster

Make `ssh` login to your Raspberry PI, and go to steps:

Step0:

Install Docker

```
sudo apt install -y libffi-dev libssl-dev python python-pip
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker pi
sudo pip install docker-compose
```

Step1: 

```
mkdir /mnt/data
cd /mnt/data
git clone https://github.com/sevrugin/docker-majordomo.git
cd docker-majordomo

```
copy deffault config and make changes
```

cp .env.example .env && nano .env
make clean
make init-all
```
All modules will be configured automatically

Also you can use `make init-app` and `make init-db` to init modules separately

Step 2: (or `-d` to start as daemon)

At first time you can use use `--build` parameter

```
docker-compose up
```

Step 4:

Go to http://your-ip-address/popup/first_start.html

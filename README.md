# docker-majordomo

Make ssh login to your Raspberry PI, and then:


Step1: 

```
mkdir /mnt/data
cd /mnt/data
git clone https://github.com/sevrugin/docker-majordomo.git
cd docker-majordomo

copy config and make changes
cp .env.example .env

make init-app
make init-db # if you see some errors just restart the command
```

Step 2:
Make changes into `./app/config.php`
```php
Define('DB_HOST', '127.0.0.1');
Define('DB_NAME', 'db_terminal');
Define('DB_USER', 'ENTER_YOUR_LOGIN');
Define('DB_PASSWORD', 'ENTER_YOUR_PASSWORD');
```

Step 3: (or `-d` to start as daemon)
At first time use "--build" parameter

```
docker-compose up
```

Step 4:

Go to http://your-ip-address/popup/first_start.html

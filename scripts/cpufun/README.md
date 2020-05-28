This script allow Raspberry Pi to manage board fun speed.

You have to made additional circuit like this
![alt text](https://micro-pi.ru/wp-content/uploads/2019/04/%D0%A1%D1%85%D0%B5%D0%BC%D0%B0-%D0%BF%D0%BE%D0%B4%D0%BA%D0%BB%D1%8E%D1%87%D0%B5%D0%BD%D0%B8%D1%8F-%D0%B2%D0%B5%D0%BD%D1%82%D0%B8%D0%BB%D1%8F%D1%82%D0%BE%D1%80%D0%B0-Orange-Pi-One-2N2222-1N4001.png)
with the difference that control pin should be connected to GP14

Next, you have to add script to `/etc/rc.local` before `exit 0`
`/mnt/data/docker-majordomo/scripts/cpufun/funspeed.py /mnt/data/docker-majordomo/data/funspeed`


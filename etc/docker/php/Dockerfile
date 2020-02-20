FROM php:7.3-fpm

RUN apt-get update && apt-get install -y mc htop procps iputils-ping
RUN docker-php-ext-install mysqli sockets

RUN        apt-get -y install supervisor && \
           mkdir -p /var/log/supervisor && \
           mkdir -p /etc/supervisor/conf.d
RUN        mkdir /var/log/supervisord

CMD /usr/bin/supervisord -n -c /etc/supervisor.conf

#RUN yes | pecl install xdebug
#RUN echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
#    && echo "xdebug.remote_enable=On" >> /usr/local/etc/php/conf.d/xdebug.ini \
#    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/xdebug.ini \
#    && echo "xdebug.remote_connect_back=Off" >> /usr/local/etc/php/conf.d/xdebug.ini \
#    && echo "xdebug.remote_autostart=On" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    if id www-data >/dev/null 2>&1 ; then userdel --force www-data; fi && \
    if getent group www-data ; then groupdel www-data; fi && \
    groupadd --gid ${GROUP_ID} www-data && \
    useradd --no-log-init --create-home --shell /bin/bash --uid ${USER_ID} --gid www-data www-data ; \
else \
    echo "\033[1;93;41m The USER_ID and GROUP_ID arguments are required..\033[0m" ; \
    exit 1 \
;fi

#USER www-data ; trouble with `supervisord`

FROM jackgruber/phpmyadmin

# See the following articles for details:
#
# https://alpinelinux.org/posts/Docker-image-vulnerability-CVE-2019-5021.html
# https://www.kennasecurity.com/20-of-the-1000-most-popular-docker-containers-have-no-root-password/
# https://gist.github.com/jgamblin/6015a2020c1de3bc3aab19b361573b7f
#
# make sure root login is disabled
RUN sed -i -e 's/^root::/root:!:/' /etc/shadow

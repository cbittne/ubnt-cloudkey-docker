FROM debian:buster

##
# Preconfigure docker image for CloudKey Environment
##

RUN apt-get update && apt-get install -y gnupg nano ca-certificates curl apt-transport-https bash wget apt-utils libterm-readline-gnu-perl dialog

# Configure official PostgreSQL APT repository
RUN echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" | tee -a /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Configure official Ubiquiti APT repository
RUN echo "deb [trusted=yes] https://apt.artifacts.ui.com stretch main release" | tee -a /etc/apt/sources.list.d/ubiquiti.list \
    # && apt-key adv --keyserver http://keyserver.ubuntu.com --recv 379CE192D401AB61 \
    && wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg 

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update \
    && apt-get upgrade -y

ENV UNIFI_CORE_ENABLED=true

##
# Install required environmental libraries and software
##

RUN apt-get install -y systemd
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \;
STOPSIGNAL SIGKILL

##
# Install PostgreSQL 10.22
##
RUN apt-get update \
    && apt-get install -y postgresql-10

##
# Install UbiOS packages
##
RUN apt-get install -y ulp-go

# Patch Version as the newest isnt released yet for some reason
#RUN sed -i 's/Version: 0.1.12-1044/Version: 0.1.18-1101/g' /var/lib/dpkg/status
#RUN sed -i 's/VersionCode: 1044/VersionCode: 1101/g' /var/lib/dpkg/status

#RUN apt-get install -y unifi-core=1.0.6 libcap2-bin
#RUN adduser unifi-core sudo
#RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/node

##
# Install UniFi Access
#
#RUN apt-get install -y unifi-access

##
# Install UniFi Protect
#

# Patch Version as the newest isnt released yet for some reason
#RUN awk '$0=="Version: 1.0.6"{$0="Version: 1.4.2"};1' /var/lib/dpkg/status  > /var/lib/dpkg/status-tmp && mv /var/lib/dpkg/status-tmp /var/lib/dpkg/status
#RUN apt-get install -y unifi-protect=1.12.5
#RUN systemctl enable unifi-protect

##
# Install UniFi LED
#
#RUN apt-get install -y unifi-led

#RUN apt-get install -y unifi 
#RUN chown -R root /var/lib/unifi /var/log/unifi /var/run/unifi
#RUN sed -i 's/UNIFI_USER:-unifi/UNIFI_USER:-root/g' /usr/lib/unifi/bin/unifi.init
#RUN sed -i 's/UNIFI_CORE_ENABLED:-"false"/UNIFI_CORE_ENABLED:-"true"/g' /usr/lib/unifi/bin/unifi.init


COPY rootfs/ /
RUN chmod +x /sbin/ubnt-systool /usr/local/bin/ubnt-tools /usr/local/bin/infinytum-initdb
RUN systemctl enable initdb
CMD ["/lib/systemd/systemd", "--log-target=journal", "--userns-remap=default"]
#CMD ["/bin/bash"]

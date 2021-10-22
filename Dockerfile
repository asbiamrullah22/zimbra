FROM ubuntu:16.04

RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
  wget \
  dialog \
  openssh-client \
  software-properties-common \
  dnsmasq \
  dnsutils \
  net-tools \
  sudo \
  rsyslog \
  openssh-server \
  unzip \
  tzdata

VOLUME ["/opt/zimbra"]

EXPOSE 22 25 465 587 110 143 993 995 80 443 8080 8443 7071

RUN echo "tzdata tzdata/Areas select Asia\ntzdata tzdata/Zones/Asia select Jakarta" > /tmp/tz ; debconf-set-selections /tmp/tz; rm /etc/localtime /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

VOLUME ["/opt/zimbra"]

COPY opt /opt/

COPY etc /etc/

RUN mv /etc/init.d/rsyslog /tmp/
RUN curl -k https://raw.githubusercontent.com/asbiamrullah22/zimbra/master/rsyslog > /etc/init.d/rsyslog
RUN chmod +x /etc/init.d/rsyslog

RUN (crontab -l 2>/dev/null; echo "1 * * * * /etc/init.d/rsyslog restart > /dev/null 2>&1") | crontab -

RUN /etc/init.d/rsyslog restart

CMD ["/bin/bash", "/opt/start.sh", "-d"]

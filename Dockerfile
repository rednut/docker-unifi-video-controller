# build docker image to run the unifi controller
#
# the unifi contoller is used to admin ubunquty wifi access points
#
# see http://community.ubnt.com/t5/UniFi-Video-Blog/UniFi-Video-3-0-5-amp-UVC-AirCam-3-0-7-Release/ba-p/882264
#
FROM rednut/ubuntu
MAINTAINER stuart nixon dotcomstu@gmail.com

ENV DEBIAN_FRONTEND noninteractive

RUN 	mkdir -p /var/log/supervisor /usr/lib/unifi/data && \
  	touch /usr/lib/unifii-video/data/.unifidatadir

RUN apt-get update -q -y
RUN apt-get install -q -y supervisor apt-utils lsb-release curl wget rsync


RUN wget -O - http://www.ubnt.com/downloads/unifi-video/apt/unifi-video.gpg.key | apt-key add -
RUN echo "http://www.ubnt.com/downloads/unifi-video/apt trusty ubiquiti" > /etc/apt/sources.list.d/ubiquity-video.list


# add ubiquity repo + key
#RUN echo "deb http://www.ubnt.com/downloads/unifi/distros/deb/ubuntu ubuntu ubiquiti" > /etc/apt/sources.list.d/ubiquity.list && \
#   apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50 && \

RUN apt-get update -q -y && \
    apt-get install -q -y unifi-video

ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME /usr/lib/unifi-video/data

# Port Forwarding

# The following ports are used on UniFi Video hosts:

# 1935, by user (RTMP video)
# 7443, by user (HTTPS), by camera (HTTPS)
# 7080, by user (HTTP), by camera (HTTP)
# 6666, by camera (video push)
# The following ports are used on cameras:

# HTTP/HTTPS ports to access web interface (optional)
# SSH to facilitate adoption by the controller on LAN (optional)
# 554 RTSP server (mandatory only on gen1)


EXPOSE  1935 7443 7080 6666 80 443 554 22
WORKDIR /usr/lib/unifi-video
CMD ["/usr/bin/supervisord"]

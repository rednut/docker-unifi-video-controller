# build docker image to run the unifi video nvr controller
#
# the unifi nvr video contoller is used to admin ubunquty ip cameras
#
#
FROM rednut/ubuntu:latest
MAINTAINER stuart nixon dotcomstu@gmail.com
ADD ./apt/ubuntu-sources.list /etc/apt/sources.list

# add local apt proxy
#RUN mkdir -p /etc/apt/apt.conf.d/ && echo 'Acquire::http { Proxy "http://apt-cacher-ng:3142"; };' >> /etc/apt/apt.conf.d/01proxy

# make apt non-interactive
ENV DEBIAN_FRONTEND noninteractive

# stop running services on install
#ENV RUNLEVEL 1

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 16126D3A3E5C1192

RUN apt-get update -q -y && apt-get install -q -y curl wget supervisor apt-utils lsb-release curl wget rsync

RUN 	mkdir -p /var/log/supervisor /data/logs /data/data && \
  	touch /data/.unifi-video

# add mongodb repo
RUN 	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
	echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list

# add ubnt repo
RUN 	wget -q -O -  http://www.ubnt.com/downloads/unifi-video/apt/unifi-video.gpg.key | apt-key add - && \
	echo "deb [arch=amd64] http://www.ubnt.com/downloads/unifi-video/apt trusty ubiquiti" | tee /etc/apt/sources.list.d/ubiquity-video.list

# update repos
RUN apt-get update -q -y

# grab unifi video contrller
RUN RUNLEVEL=1 apt-get install -q -y unifi-video

# launcher config
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN	mkdir -p /data/data /data/logs && \
	 ls -la /data/
	
# link data dir
#RUN 	cat /etc/passwd
#RUN 	cat /etc/group
#RUN 	chown -Rv unifi-video:unifi-video /data/logs /data/data
#RUN	chmod -Rv a+rwX /data/data /data/logs



# link data dir
RUN 	ln -fs /data/data /usr/lib/unifi-video/data && \
	ln -fs /data/data /var/lib/unifi-video && \
 	ln -fs /data/logs /usr/lib/unifi-video && \
	ln -fs /data/logs /var/log/unifi-video

VOLUME /data
VOLUME /data/data
VOLUME /data/logs

VOLUME /var/lib/unifi-video
VOLUME /var/log/unifi-video
VOLUME /usr/lib/unifi-video

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

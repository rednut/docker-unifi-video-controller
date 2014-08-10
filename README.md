Docker container for UniFi video NVR controller
===============================================
Dockerisation of UniFi video controller.

Building docker image
---
The Dockerfile will provision the image with ubuntu:latest and all the required dependencies to run the UniFi video NVR controller.

The UniFi NVR controller repo will provide the .debs. The package requires mongodb, so if we don't include 10gen's official repo it will use stock debian mongo instead (current state).

The supervisor.conf is provided to configure supervisord which is used to launch the UniFi contoller daemon.

	git clone https://github.com/rednut/docker-unifi-video-controller.git
	cd docker-unifi-video-controller
	docker build -t=rednut/unifi-video .

or 

	docker pull rednut/dockerfile-unifi-video

Launching the UniFi video controller daemon
---
To launch a container using the image created earlier:

	docker run -d --privileged \
		-p 1935:1935 -p 7443:7443 -p 7080:7080 -p 6666:6666 -p 554:554 \
                -v /srv/data/apps/docker/unifi-video/data:/data/data \
                -v /srv/data/apps/docker/unifi-video/logs:/data/logs \
                 --name=unifi-video rednut/unifi-video:latest

 

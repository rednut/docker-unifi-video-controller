docker container for unifi video ncr controller
===============================================

* dockerisation of unifi video controller

** building docker image

git clone $dockerfile-unifi-video
cd dockerfile-unifi-video

the Dockerfile will provision the image with ubuntu:latest and all the required dependencies to 
run the unifi video nvr controller.

The unifi nvr controller repo will provide the .debs. The package requires mongodb, so if we dont
include 10gen's official repo it will use stock debian mongo instead (current state)

The supervisor.conf is provided to configure supervisord which is used to launch the UniFi contoller daemon.

	cd path/to/dockerfiledir
	docker build -t=rednut/unifi-video .

or 
	
	docker pull rednut/dockerfile-unifi-video


** run the container: launching the unifi video controller daemon

 to launch a container using the image created earlier:

	docker run -d --privileged \
		-p 1935:1935 -p 7443:7443 -p 7080:7080 -p 6666:6666 -p 554:554 \                                                                                                                   [16:04]
                -v /srv/data/apps/docker/unifi-video/data:/data/data \
                -v /srv/data/apps/docker/unifi-video/logs:/data/logs \
                 --name=unifi-video rednut/unifi-video:latest

 

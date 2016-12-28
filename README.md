Docker container for UniFi video NVR controller
===============================================
Dockerisation of UniFi video controller.

Building docker image
---
The Dockerfile will provision the image with ubuntu:latest and all the required dependencies to run the UniFi video NVR controller.

The UniFi NVR controller repo will provide the .debs. The package requires mongodb, so if we don't include 10gen's official repo it will use stock Debian mongo instead (current state).

The supervisor.conf is provided to configure supervisord which is used to launch the UniFi controller daemon.

	git clone https://github.com/rednut/docker-unifi-video-controller.git
	cd docker-unifi-video-controller
	docker build -t=rednut/unifi-video .

or 

	docker pull rednut/unifi-video-controller

Launching the UniFi video controller daemon
---
The following is a _rough_ overview of how to lunch / run the video controller container, you will need to amend host volume path and ports first.

To launch a container using the image created earlier:

	docker run -d --privileged \
		-p 1935:1935 -p 7443:7443 -p 7080:7080 -p 6666:6666 -p 554:554 -p 7447:7447 -p 8880:80 -p 4443:443 \
                -v /srv/data/apps/docker/unifi-video/data:/var/lib/unifi-video \
                -v /srv/data/apps/docker/unifi-video/logs:/var/log/unifi-video \
                 --name=unifi-video rednut/unifi-video:latest

Remember to adjust the ports and volume paths to suite your environment.



----
Sample system.properties (should go into /data/data/system.properties):

```
cat    system.properties
```

	# unifi-video v3.0.8
	#Mon Nov 17 21:43:06 GMT 2014
	app.db.host=REPLACE_ME_WITH_YOUR_MONGO_DB_IP
	app.db.port=27017
	db.external=true
	is_default=false
	system_ip=REPLACE_ME_WITH_YOUR_PUBLIC_IP
	timezone=Europe/London
	# app.http.port = 7080
	# app.https.port = 7443
	# ems.liveflv.port = 6666
	# ems.rtmp.port = 1935
	# ems.rtsp.port = 7447	

Hint: copy this in once your have initial install+db working, then customise!



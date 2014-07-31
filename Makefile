USER = rednut
NAME = unifi-video
REPO = $(USER)/$(NAME)
VERSION = $(shell touch VERSION && cat VERSION)

LVOL = /srv/data/apps/docker/unifi-video

.PHONY: all build test tag_latest release ssh

all: build tag_latest run

stop:
	@docker stop $(NAME)

rmcontainer:
	@docker rm $(NAME)

dockerps:
	@docker ps | grep -i $(NAME)
	@docker ps -a | grep -i $(NAME)

clean: stop rmcontainer dockerps

build: version_bump build_full tag_latest

build_lite:
	@docker build -t="$(REPO):$(VERSION)" --rm  .

build_full:
	@docker build -t="$(REPO):$(VERSION)" --rm --no-cache .

version_bump:
	VERSION inc

tag_latest:
	docker tag $(REPO):$(VERSION) $(REPO):latest

release: test tag_latest
	@if ! docker images $(REPO) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(REPO) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(REPO)
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"


# 1935, by user (RTMP video)
# 7443, by user (HTTPS), by camera (HTTPS)
# 7080, by user (HTTP), by camera (HTTP)
# 6666, by camera (video push)

run: 
	echo docker run -d --privileged -p 1935:1935 -p 7443:7443 -p 7080:7080 -p 6666:6666 -p 554:554 \
                        -v $(LVOL)/data:/var/lib/unifi-video \
			-v $(LVOL)/logs:/var/log/unifi-video \
			 --name=$(NAME) $(REPO):latest

ip:
	@ID=$$(docker ps | grep -F "$(REPO):$(VERSION)" | awk '{ print $$1 }') && \
                if test "$$ID" = ""; then echo "Container is not running."; exit 1; fi && \
                IP=$$(docker inspect $$ID | grep IPAddr | sed 's/.*: "//; s/".*//') && \
                echo "$$IP\tsabnzbd"

ssh:
	chmod 600 image/insecure_key
	@ID=$$(docker ps | grep -F "$(REPO):$(VERSION)" | awk '{ print $$1 }') && \
		if test "$$ID" = ""; then echo "Container is not running."; exit 1; fi && \
		IP=$$(docker inspect $$ID | grep IPAddr | sed 's/.*: "//; s/".*//') && \
		echo "SSHing into $$IP" && \
		ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i image/insecure_key root@$$IP

# yams-docker

A Docker image for [yams](https://github.com/Berulacks/yams).

## Available Archs on Docker Hub

- linux/amd64
- linux/arm/v7
- linux/arm64/v8

## References

First and foremost, the reference to the projects:

[Yams](https://github.com/Berulacks/yams)
[Music Player Daemon](https://www.musicpd.org)  
Current version of yams if `0.7.3`.

## Links

Source: [GitHub](https://github.com/giof71/yams-docker)  
Images: [DockerHub](https://hub.docker.com/r/giof71/yams)

## Why

I just wanted to be able to run `yams` using a docker container.  
I wanted to be able to use it on Moode Audio also.  

## Prerequisites

See [this](https://github.com/GioF71/yams-docker/blob/main/doc/prerequisites.md) page.  
The page also covers docker installation on Moode Audio.  

## Get the image

Here is the [repository](https://hub.docker.com/repository/docker/giof71/yams) on DockerHub.

Getting the image from DockerHub is as simple as typing:

`docker pull giof71/yams`

## Usage

### Volumes

The following tables lists the volumes:

VOLUME|DESCRIPTION
:---|:---
/data|Application data. It is recommended to setup this volume.

### Environment Variables

VARIABLE|DESCRIPTION
:---|:---
USER_MODE|Defaults to `YES`
PUID|User id, defaults to `1000`
PGID|Group id, defaults to `1000`
MPD_HOST|Host for Music Player daemon, defaults to `localhost`, which is generally correct when the container is run in `host` mode.
MPD_PORT|Defaults to `6600`
SESSION_FILE|Specify the location of the session file.

#### Some Notes

About `SESSION_FILE`, you will need to make sure it indicates a path which is accessible to the container.

### First run

The first run should be interactive, because you will receive the link to be opened in order to authorize yams to access your Last.FM account.  
After this initial configuration, if you have setup the volume correctly, you will be able to run the container non interactively.

### Example configuration

Please see the following docker-compose file:

```text
---
version: "3"

networks:
  mpd-pulse:
    external: true

services:
  yams:
    image: giof71/yams:latest
    container_name: yams-pulse
    networks:
      - mpd-pulse
    environment:
      - TZ=Europe/Rome
      - PUID=1000
      - PGID=1000
      - MPD_HOST=mpd-pulse
    volumes:
      - ./data:/data
```

This container runs in the same docker network named `mpd-pulse`, so we can refer to mpd using its container name, assuming mpd is running in a docker container (see my repo [here](https://github.com/GioF71/mpd-alsa-docker)).  
Another example, using host networking:

```text
---
version: "3"

services:
  yams:
    image: giof71/yams:latest
    container_name: yams-pulse
    network_mode: host
    environment:
      - TZ=Europe/Rome
      - PUID=1000
      - PGID=1000
      - MPD_HOST=mpd-hostname.home.lan
      - MPD_PORT=6601
    volumes:
      - ./data:/data
```

This time we don't have a docker network, and if mpd is not running on localhost, we can specify hostname and port using `MPD_HOST` and `MPD_PORT`. Both can be omitted if the values are respectively `localhost` and `6600`.  
In both cases, for the first interactive run, execute the following:

```text
docker-compose run yams
```

Please note that `yams` here is the name of the service in the docker-compose file.  
Follow the instructions on the console, so open the link and authorized the application on Last.FM. Press `enter` on the console as requested.  
After this step, you can simply stop the container (`CTRL-C`, maybe twice to trigger a kill), then restart it as usual with:

```text
docker-compose up -d
```

### Changes

See the following table.

Date|Description
:---|:---
2025-08-02|Corrected session path
2025-08-02|Add support for arm/v5
2025-08-02|Updated GitHub action versions
2025-08-02|Remove switch to /tmp if /data is not writable
2024-10-07|Use exec so we can get rid of bash processes
2023-04-19|Routine build after updates to the upstream project
2023-03-09|Support for `API_KEY` and `API_SECRET` ([#13](https://github.com/GioF71/yams-docker/issues/13))
2023-03-04|Add apt proxy support ([#4](https://github.com/GioF71/yams-docker/issues/4))
2023-03-04|Removing existing pid before restart ([#5](https://github.com/GioF71/yams-docker/issues/5))
2023-03-04|Fixed volume in Dockerfile ([#1](https://github.com/GioF71/yams-docker/issues/1))
2023-03-03|Initial release

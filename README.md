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

## Prerequisites

See [this](https://github.com/GioF71/yams-docker/blob/main/doc/prerequisites.md) page.

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

### First run

The first run should be interactive, because you will receive the link to be opened in order to authorize yams to access your Last.FM account.  
After this initial configuration, if you have setup the volume correctly, you will be able to run the container non interactively.

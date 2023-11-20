# Prerequisites

You need to have Docker up and running on a Linux machine, and the current user must be allowed to run containers (this usually means that the current user belongs to the "docker" group).

You can verify whether your user belongs to the "docker" group with the following command:

`getent group | grep docker`

This command will output one line if the current user does belong to the "docker" group, otherwise there will be no output.

The Dockerfile and the included scripts have been tested on the following distros:

- Manjaro Linux with Gnome (amd64)
- Asus Tinkerboard
- Raspberry Pi 3 and 4, both 32bit and 64bit

As I test the Dockerfile on more platforms, I will update this list.

## Moode Audio

We can install yams also on Moode Audio.  
Assuming you have ssh access, you simply need to install docker packages:

```text
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo usermod -a -G docker $USER
```

You might need to log out and in again.  
After this step, follow the instructions in the [README.md](https://github.com/GioF71/yams-docker/blob/main/README.md) file.

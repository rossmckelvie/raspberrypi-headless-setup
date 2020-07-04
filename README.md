# raspberrypi-headless-setup
Use Packer for ARM to build base images & deploy images with personalized cloud-init config on flash.

## Usage
The filepaths under the `files` directory represent the ultimate destination directory structure, ie `files/etc/cloud/cloud.cfg` is expected to be on the pi at `/etc/cloud/cloud.cfg`.

Packer scripts and general bash commands for configuring the machines are in the `packer` directory.

To save time while developing new images, my personal workflow is to build the base image and then build on top of that, sort of like docker layers. Each time the base is updated, I will need to update the sha hash in downstream projects otherwise it will reuse the old image in packer_cache directory.

### Dependencies
This project uses the following dependencies:
- Docker for Mac >= 2.3.2.0 (currently in edge)
- [`packer-build-arm-image`](https://github.com/solo-io/packer-builder-arm-image/) in this repo I use the public docker image, but you can checkout this repo if you need to customize the build environment and build a custom docker image
- [`flash`](https://github.com/hypriot/flash) command to add in cloud-init at time of flash

### Personalize
Clone and modify the user data to personalize
```shell
cp files/boot/user-data.example.yaml files/boot/user-data.yaml
cp files/boot/wpa_supplicant.example.conf files/boot/wpa_supplicant.conf
```

You can also set the hostname while flashing, view the `Makefile` flash commands for more info.

### Building
- `make img` to build the image.
- `make flash` to flash the built image.
- `make all` to build + flash.


## Notes & Learnings
- In Buster, the wpa_applicant.conf file needs to go into `/boot` for wifi to be unblocked. ([source](https://www.raspberrypi.org/forums/viewtopic.php?p=1653844#p1653844))
  - Unfortunately this means that we will be inserting it via packer instead of cloud-init, which makes sharing the images and building for yourself a little more cumbersome.

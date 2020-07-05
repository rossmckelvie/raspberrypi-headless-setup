# raspberrypi-headless-setup
Use Packer for ARM to build base images & deploy images with personalized cloud-init config on flash.

This repository should serve as an example of file structure and scripts that you can use for your own projects. This combines a few different techniques for headless setup of raspberry pis - running the make commands should generate valid images with no modifications to this project and provide a great starting point for adding some DevOps to your homelab.

## My Projects
`base` - Adds my wpa_supplicant, configures locale, installs `vim`, `git`, and other common helpful tools. A nice clean slate preconfigured with WiFi connectivity if I can't run ethernet to that Pi. I target the output of this image as the iso input to other projects to save time from the initial installs and updates.

`rtl-sdr` - Fully headless installation and configuration of an amateur radio APRS i-gate station. Uses [direwolf](https://github.com/wb2osz/direwolf) and an [RTL-SDR kit](https://www.rtl-sdr.com/) to relay APRS signals [to the internet](https://aprs.fi/).

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
Clone and modify the files below to personalize your setup. All non-example files are gitignored, but make sure to at least create these files to avoid packer errors.

Set up your public SSH key for passwordless entry:
```shell
cp files/boot/user-data.example.yaml files/boot/user-data.yaml
```

Set up WiFi connections:
```shell
cp files/boot/wpa_supplicant.example.conf files/boot/wpa_supplicant.conf
```

For SDR image, set your callsign, coordinates, and other config:
```shell
cp files/home/pi/direwolf/sdr.example.conf files/home/pi/direwolf/sdr.conf
```

You can also set the hostname while flashing, view the `Makefile` flash commands for more info.

### Building
- `make img-base` to build the base image.
- `make flash-base` to flash the built base image.
- `make img-sdr` to build the sdr image. Make sure to update hash for base image.
- `make flash-base` to flash the built sdr image.
- `make all` to build + flash.


## Notes & Learnings
- In Buster, the wpa_applicant.conf file needs to go into `/boot` for wifi to be unblocked. ([source](https://www.raspberrypi.org/forums/viewtopic.php?p=1653844#p1653844))
  - Unfortunately this means that we will be inserting it via packer instead of cloud-init, which makes sharing the images and building for yourself a little more cumbersome.

all: docker img-base image-sdr

clean:
	rm -f output-arm-image/image

docker:
	docker pull docker.pkg.github.com/solo-io/packer-builder-arm-image/packer-builder-arm

img-base: docker clean
	docker run \
		--rm \
		--privileged \
		-v ${PWD}:/build:ro \
		-v ${PWD}/packer_cache:/build/packer_cache \
		-v ${PWD}/output-arm-image:/build/output-arm-image \
		-e PACKER_CACHE_DIR=/build/packer_cache \
	docker.pkg.github.com/solo-io/packer-builder-arm-image/packer-builder-arm build packer/base.json
	mv output-arm-image/image output-arm-image/base.img

flash-base:
	flash --force \
		--userdata ./files/boot/user-data.yaml  \
		./output-arm-image/base.img

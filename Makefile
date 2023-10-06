AUTHOR?=imanuelchandra
REPOSITORY?=pxe-boot

.PHONY: build
build_pxe_boot:
	docker build -t ${AUTHOR}/${REPOSITORY}:${PXE_BOOT_SERVER_VERSION}  . \
			--progress=plain \
			--no-cache
	@echo
	@echo "Build finished. Docker image name: \"${AUTHOR}/${REPOSITORY}:${PXE_BOOT_SERVER_VERSION}\"."

.PHONY: run
run_pxe_boot:
	docker run -it --rm --privileged=True --init --user 6565:6565 --net host \
	        -v ./config:/config \
			-v ./data:/data \
			-v ./log:/log \
			-v ./scripts:/scripts \
			-p 2049:2049 \
			${AUTHOR}/${REPOSITORY}:${PXE_BOOT_SERVER_VERSION} eth0
M_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
OUT_DIR := $(M_DIR)/out
Z_DIR := $(M_DIR)/zephyr
Z_VER := 1.4.0
ZSDK_VER := 0.8.1
P-X86 ?= $(Z_DIR)/samples/hello_world/microkernel
P-ARC ?= $(Z_DIR)/samples/hello_world/nanokernel

help:
	@echo "Install dependencies: sudo make install-dep"
	@echo "Set up the build env: make setup"
	@echo "Compile: make compile P-X86=<x86 project path> P-ARC=<arc project path>"
	@echo "Upload: make upload"

check-root:
	@if [ `whoami` != root ]; then echo "Please run as sudoer/root" ; exit 1 ; fi

install-dep: check-root
	apt-get update
	apt-get install -y git make gcc gcc-multilib g++ libc6-dev-i386 g++-multilib python3-ply

setup:
	@./install-zephyr.sh $(Z_VER) $(ZSDK_VER)

check-source:
	@if [ -z "$(value ZEPHYR_BASE)" ]; then echo "Please run: source zephyr/zephyr-env.sh" ; exit 1 ; fi

compile: check-source
	@test -d out || mkdir out
	@echo Compiling x86 core
	make O=$(OUT_DIR)/x86 BOARD=arduino_101_factory ARCH=x86 -C $(P-X86)
	@echo Compiling ARC core
	make O=$(OUT_DIR)/ARC BOARD=arduino_101_sss_factory ARCH=arc -C $(P-ARC)

upload:
	@echo Uploading compiled binaries

clean:
	rm -rf $(OUT_DIR)

.PHONY: help check-root install-dep setup compile upload clean

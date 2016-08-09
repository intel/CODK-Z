M_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
OUT_DIR := $(M_DIR)/out
Z_DIR := $(M_DIR)/../zephyr
Z_DIR_REL := $(shell $(M_DIR)/relpath "$(M_DIR)" "$(Z_DIR)")
Z_VER := 1.4.0
ZSDK_VER := 0.8.1
SW_DIR := $(M_DIR)/software
FW_DIR := $(M_DIR)/firmware
P-X86 ?= $(SW_DIR)/examples/hello
P-ARC ?= $(FW_DIR)/examples/hello
export CODK_DIR ?= $(M_DIR)

help:
	@echo "Install dependencies: sudo make install-dep"
	@echo "Set up the build env: make setup"
	@echo "Compile: make compile P-X86=<x86 project path> P-ARC=<arc project path>"
	@echo "Upload via DFU: make upload-dfu"
	@echo "Upload via JTAG: make upload-jtag"

check-root:
	@if [ `whoami` != root ]; then echo "Please run as sudoer/root" ; exit 1 ; fi

install-dep: check-root
	apt-get update
	apt-get install -y git make gcc gcc-multilib g++ libc6-dev-i386 g++-multilib python3-ply
	cp -f $(M_DIR)/utils/drivers/rules.d/*.rules /etc/udev/rules.d/

setup:
	@./install-zephyr.sh $(Z_VER) $(ZSDK_VER)

check-source:
	@if [ -z "$(value ZEPHYR_BASE)" ]; then echo "Please run: source $(Z_DIR_REL)/zephyr-env.sh" ; exit 1 ; fi

compile: compile-firmware compile_software

compile-firmware: check-source
	@test -d out || mkdir out
	@echo Compiling x86 core
	make O=$(OUT_DIR)/x86 BOARD=arduino_101_factory ARCH=x86 -C $(P-X86)

compile-software: check-source 
	@test -d out || mkdir out
	@echo Compiling ARC core
	make O=$(OUT_DIR)/arc BOARD=arduino_101_sss_factory ARCH=arc -C $(P-ARC)

upload-dfu:
	@echo Uploading compiled binaries using DFU
	$(M_DIR)/utils/flash_dfu.sh -a $(M_DIR)/out/arc/zephyr.bin -x $(M_DIR)/out/x86/zephyr.bin

upload-jtag:
	@echo Uploading compiled binaries using JTAG
	$(M_DIR)/utils/flash_jtag.sh -a $(M_DIR)/out/arc/zephyr.bin -x $(M_DIR)/out/x86/zephyr.bin

clean: check-source
	rm -rf $(OUT_DIR)

.PHONY: help check-root install-dep setup compile upload clean

TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CODK_FLASHPACK_URL := https://github.com/01org/CODK-Z-Flashpack.git
CODK_FLASHPACK_DIR := $(TOP_DIR)/flashpack
CODK_FLASHPACK_TAG := master
OUT_DIR := $(TOP_DIR)/out
ZEPHYR_DIR := $(TOP_DIR)/../zephyr
ZEPHYR_DIR_REL = $(shell $(CODK_FLASHPACK_DIR)/relpath "$(TOP_DIR)" "$(ZEPHYR_DIR)")
ZEPHYR_VER := 1.4.0
ZEPHYR_SDK_VER := 0.8.1
FW_DIR := $(TOP_DIR)/firmware
SW_DIR := $(TOP_DIR)/software
FWPROJ_DIR ?= $(FW_DIR)/examples/hello
SWPROJ_DIR ?= $(SW_DIR)/examples/hello
CODK_DIR ?= $(TOP_DIR)

help:

check-root:
	@if [ `whoami` != root ]; then echo "Please run as sudoer/root" ; exit 1 ; fi

install-dep: check-root
	apt-get update
	apt-get install -y git make gcc gcc-multilib g++ libc6-dev-i386 g++-multilib python3-ply
	cp -f $(CODK_FLASHPACK_DIR)/drivers/rules.d/*.rules /etc/udev/rules.d/

setup: clone
	@$(CODK_FLASHPACK_DIR)/install-zephyr.sh $(ZEPHYR_VER) $(ZEPHYR_SDK_VER)

clone: $(CODK_FLASHPACK_DIR)

$(CODK_FLASHPACK_DIR):
	git clone -b $(CODK_FLASHPACK_TAG) $(CODK_FLASHPACK_URL) $(CODK_FLASHPACK_DIR)

check-source:
	@if [ -z "$(value ZEPHYR_BASE)" ]; then echo "Please run: source $(ZEPHYR_DIR_REL)/zephyr-env.sh" ; exit 1 ; fi

compile: compile-firmware compile-software

compile-firmware: check-source
	@test -d out || mkdir out
	@echo Compiling x86 core
	$(MAKE) O=$(OUT_DIR)/x86 BOARD=arduino_101_factory ARCH=x86 -C $(FWPROJ_DIR)

compile-software: check-source
	@test -d out || mkdir out
	@echo Compiling ARC core
	$(MAKE) O=$(OUT_DIR)/arc BOARD=arduino_101_sss_factory ARCH=arc -C $(SWPROJ_DIR)

upload: upload-firmware-dfu upload-software-dfu

upload-firmware-dfu:
	$(CODK_FLASHPACK_DIR)/flash_dfu.sh -x $(OUT_DIR)/x86/zephyr.bin

upload-software-dfu:
	$(CODK_FLASHPACK_DIR)/flash_dfu.sh -a $(OUT_DIR)/arc/zephyr.bin

upload-jtag: upload-firmware-jtag upload-software-jtag

upload-firmware-jtag:
	$(CODK_FLASHPACK_DIR)/flash_jtag.sh -x $(OUT_DIR)/x86/zephyr.bin

upload-software-jtag:
	$(CODK_FLASHPACK_DIR)/flash_jtag.sh -a $(OUT_DIR)/arc/zephyr.bin

clean: check-source
	rm -rf $(OUT_DIR)
	

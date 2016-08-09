# Curie Open Development Kit - Z

### Contents

  - Firmware: Zephyr application
  - Software: Zephyr application

### Supported Platforms
 - Ubuntu 14.04 - 64 bit

### Installation
```
mkdir CODK && cd $_
git clone https://github.com/01org/CODK-Z.git
cd CODK-Z
sudo make install-dep
make setup
source ../zephyr/zephyr-env.sh
```

### Compile
- Firmware: `make compile-firmware`
- Software: `make compile-software`
- Both: `make compile`

### Upload

##### Using USB/DFU
- Firmware: `make upload-firmware-dfu`
- Software: `make upload-software-dfu`
- Both: `make upload`

##### Using JTAG
- Firmware: `make upload-firmware-jtag`
- Software: `make upload-software-jtag`
- Both: `make upload-jtag`

### Debug
- Coming soon

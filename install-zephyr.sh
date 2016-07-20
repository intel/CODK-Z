#!/bin/bash -e
Z_VER="$1"
ZSDK_VER="$2"
Z_PATH=$(readlink -m "$(pwd)/../zephyr")
ZSDK_FILE="zephyr-sdk-${ZSDK_VER}-i686-setup.run"
ZSDK_PATH=$(readlink -m "$(pwd)/../zephyr-sdk")

if [ -d "../zephyr" ]; then
    echo "Zephyr source already exists. Skipping installation."
else
    echo "Downloading Zephyr"
    curl -sL http://bit.ly/1Y6G8d2 | tar xz
    echo "Installing Zephyr to ${Z_PATH}"
    mv zephyr-v${Z_VER} ${Z_PATH}
fi

if [ -d "../zephyr-sdk" ]; then
    echo "Zephyr SDK already exists. Skipping installation."
else
    if [ ! -f ${ZSDK_FILE} ] ; then
        echo "Downloading Zephyr SDK"
        curl -OL https://nexus.zephyrproject.org/content/repositories/releases/org/zephyrproject/zephyr-sdk/${ZSDK_VER}-i686/${ZSDK_FILE}
        chmod 755 zephyr-sdk-${ZSDK_VER}-i686-setup.run
    fi
    echo "Installing Zephyr SDK to ${ZSDK_PATH}"
    { echo "${ZSDK_PATH}"; } | ./${ZSDK_FILE} --nox11
fi

if [ -f ~/.zephyrrc ] ; then
    echo "~/.zephyrrc already exists. Skipping setting options."
else
    echo "Setting options in ~/.zephyrrc"
    echo "export ZEPHYR_GCC_VARIANT=zephyr" > ~/.zephyrrc
    echo "export ZEPHYR_SDK_INSTALL_DIR=~/zephyr-sdk" >> ~/.zephyrrc
fi

echo "Please run: source zephyr/zephyr-env.sh"

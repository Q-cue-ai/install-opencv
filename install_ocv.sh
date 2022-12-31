#!/bin/bash

set -e

OPENCV_TAR_GZ_PATH=$1

if [[ ! -f ${OPENCV_TAR_GZ_PATH} ]]; then
    echo "Bad input file: ${OPENCV_TAR_GZ_PATH}"
    echo "please provide full path to opencv tar gz file"
    echo ""
    exit 1
fi

echo "This will install ${OPENCV_TAR_GZ_PATH} to /usr/local/"
sudo tar -xzf ${OPENCV_TAR_GZ_PATH} -C /usr/local
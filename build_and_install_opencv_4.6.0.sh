#!/bin/bash

set -e

if [[ ${OSTYPE} =~ "darwin" ]]; then
    HOMEBREW_NO_AUTO_UPDATE=1 brew install cmake gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav
else
    sudo apt update && sudo apt install -y git make cmake build-essential \
                    libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
                    gstreamer1.0-libav libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
                    libgtk2.0-dev
fi

pip3 install numpy

TMPDIR=$(mktemp -d)
GIT_BRANCH=master
OPENCV_INSTALL_DIR=/usr/local
OPENCV_BUILD_DIR=opencv_build
if [ ! -z ${1} ]; then
    GIT_BRANCH=${1}
fi

pushd "${TMPDIR}" > /dev/null
    echo ""
    echo "Cloning OpenCV and OpenCV Contrib from branch: ${GIT_BRANCH}"
    echo ""
    git clone --depth 1 --branch ${GIT_BRANCH} https://github.com/opencv/opencv.git "${TMPDIR}"/opencv
    git clone --depth 1 --branch ${GIT_BRANCH} https://github.com/opencv/opencv_contrib.git "${TMPDIR}"/opencv_contrib

    echo ""
    echo "-------------------------------------------"
    echo "Compiling OpenCV, this may take a while..."
    echo "-------------------------------------------"
    echo ""

    mkdir ${OPENCV_BUILD_DIR}
    pushd "${OPENCV_BUILD_DIR}" > /dev/null
        cmake -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_INSTALL_PREFIX=${OPENCV_INSTALL_DIR} \
            -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules \
            -D INSTALL_PYTHON_EXAMPLES=OFF \
            -D INSTALL_C_EXAMPLES=OFF \
            -D BUILD_opencv_python2=OFF \
            -D BUILD_opencv_python3=ONPf \
            -D OPENCV_ENABLE_NONFREE=ON \
            -D PYTHON3_EXECUTABLE=$(which python3.10) \
            -D PYTHON3_INCLUDE_DIR=$(python3.10 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
            -D PYTHON3_PACKAGES_PATH=$(python3.10 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
            -D WITH_GSTREAMER=ON \
            -D BUILD_ZLIB=OFF \
            -D BUILD_EXAMPLES=OFF ../opencv

        make -j8

        echo ""
        echo "-------------------------------------------"
        echo "Installing OpenCV to: ${OPENCV_INSTALL_DIR}"
        echo "-------------------------------------------"
        echo ""

        sudo make install
    popd > /dev/null
popd > /dev/null

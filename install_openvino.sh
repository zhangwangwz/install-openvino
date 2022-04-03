#!/bin/bash
 sudo -E apt update
 sudo -E apt-get install -y \
              build-essential \
              curl \
              wget \
              libssl-dev \
              ca-certificates \
              git \
              libboost-regex-dev \
              libgtk2.0-dev \
              pkg-config \
              unzip \
              automake \
              libtool \
              autoconf \
              libcairo2-dev \
              libpango1.0-dev \
              libglib2.0-dev \
              libgtk2.0-dev \
              libswscale-dev \
              libavcodec-dev \
              libavformat-dev \
              libgstreamer1.0-0 \
              gstreamer1.0-plugins-base \
              libusb-1.0-0-dev \
              libopenblas-dev
if apt-cache search --names-only '^libpng12-dev'| grep -q libpng12; then
    sudo -E apt-get install -y libpng12-dev
else
    sudo -E apt-get install -y libpng-dev
fi

current_cmake_version=$(cmake --version | sed -ne 's/[^0-9]*\(\([0-9]\.\)\{0,4\}[0-9][^.]\).*/\1/p')
required_cmake_ver=3.17
if [ ! "$(printf '%s\n' "$required_cmake_ver" "$current_cmake_version" | sort -V | head -n1)" = "$required_cmake_ver" ]; then
    wget "https://github.com/Kitware/CMake/releases/download/v3.18.4/cmake-3.18.4.tar.gz"
    tar xf cmake-3.18.4.tar.gz
    (cd cmake-3.18.4 && ./bootstrap --parallel="$(nproc --all)" && make --jobs="$(nproc --all)" && sudo make install)
    rm -rf cmake-3.18.4 cmake-3.18.4.tar.gz
fi

cd ~/openvino
pip install -r src/bindings/python/src/compatibility/openvino/requirements-dev.txt --user
mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=/opt/intel/openvino \
	 -DCMAKE_BUILD_TYPE=Release \
	 -DENABLE_OPENCV=ON \
	 -DENABLE_PYTHON=ON \
	 -DNGRAPH_PYTHON_BUILD_ENABLE=ON \
	 -DNGRAPH_ONNX_IMPORT_ENABLE=ON \
	 -DPYTHON_EXECUTABLE=`which python3.9` \
	 -DPYTHON_LIBRARY=/usr/lib/aarch64-linux-gnu/libpython3.9.so \
	 -DPYTHON_INCLUDE_DIR=/usr/include/python3.9 \
	 -DENABLE_OV_ONNX_FRONTEND=ON \
	 -DWITH_TBB=ON ..

make --jobs=$(nproc --all) 
sudo make install
echo "source /opt/intel/openvino/setupvars.sh" >> ~/.bashrc
source ~/.bashrc
sudo usermod -a -G users "$(whoami)"
bash /opt/intel/openvino/install_dependencies/install_NCS_udev_rules.sh
cd ~
git clone https://github.com/openvinotoolkit/open_model_zoo.git
cd ~/open_model_zoo/tools/model_tools
pip install --upgrade pip
pip install . --user


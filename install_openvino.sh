#!/bin/bash
 sudo -E apt update
 sudo apt-get dist-upgrade -y
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
              libopenblas-dev \
	    ca-certificates \
	    autoconf \
	    automake \
	    libtool \
	    zlib1g zlib1g-dev \
	    bash-completion \
	    locate curl \
	    cpio libtinfo-dev jq \
	    libusb-1.0-0-dev patchelf \
	    python3-venv
if apt-cache search --names-only '^libpng12-dev'| grep -q libpng12; then
    sudo -E apt-get install -y libpng12-dev
else
    sudo -E apt-get install -y libpng-dev
fi

cd ~
sudo rm -rf openvino* 
git clone https://github.com/openvinotoolkit/openvino.git --recursive
#git clone https://gitcode.net/mirrors/openvinotoolkit/openvino.git --recursive
cd ~/openvino
git submodule update --init --recursive
while [ $? -ne 0 ]
do
	git submodule update --init --recursive
done
cd ~
git clone https://github.com/openvinotoolkit/openvino_contrib.git --recursive
cd ~/openvino_contrib
git submodule update --init --recursive
while [ $? -ne 0 ]
do
	git submodule update --init --recursive
done
cd ~/openvino
pip install -r src/bindings/python/src/compatibility/openvino/requirements-dev.txt 
pip install onnx --upgrade
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
	 -DIE_EXTRA_MODULES=~/openvino_contrib/modules \
	 -DWITH_TBB=ON ..

make --jobs=$(nproc --all) 
sudo make install
echo "source /opt/intel/openvino/setupvars.sh" >> ~/.bashrc
source ~/.bashrc
sudo usermod -a -G users "$(whoami)"
bash /opt/intel/openvino/install_dependencies/install_NCS_udev_rules.sh
cd ~
python -c "import openvino"
if [ $? -ne 0 ];then
	echo "Failed"
else
	ls open_model_zoo*
	if [ $? -ne 0 ];then
		echo "Open Model Zoo has been installed, ignoring"
	else
		git clone https://github.com/openvinotoolkit/open_model_zoo.git
		#git clone https://gitee.com/zhang-huanshu/open_model_zoo.git --recursive
		cd ~/open_model_zoo/tools/model_tools
		pip install --upgrade pip
		pip install . 
		pip install ~/open_model_zoo/demos/common/python
	fi
	pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu --upgrade
	cd ~
	git clone https://github.com/openvinotoolkit/openvino_tensorflow.git --recursive
	cd ~/openvino_tensorflow
	git submodule update --init --recursive
	while [ $? -ne 0 ]
	do
		git submodule update --init --recursive
	done
	pip install psutil --upgrade
	python build_ovtf.py --tf_version=v2.8.0 --use_openvino_from_location=/opt/intel/openvino/
	echo "Success"
fi



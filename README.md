# install-openvino

Install openvino in Raspberry Pi

Usage:

```shell
pip install tensorflow-2.6.0-cp39-cp39-linux_aarch64.whl --user
cd ~
git clone https://github.com/openvinotoolkit/openvino.git --recursive
#git clone https://gitcode.net/mirrors/openvinotoolkit/openvino.git --recursive
git submodule update --init --recursive
cd openvino
sudo chmod 755 install_openvino.sh
bash install_openvino.sh
```

Openvino will be installed in /opt/intel/openvino

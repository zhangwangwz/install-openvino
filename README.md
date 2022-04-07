# install-openvino

Install openvino and open model zoo in Raspberry Pi 4

Requirements: opencv==4.5.5 Tensorflow==2.8.0 python==3.9

if you have installed openvino before and want to reinstall openvino, please make sure that you have deleted

```shell
source /path/to/openvino/setupvars.sh
```
from ~/.bashrc and reboot.

Usage:

```shell
sudo chmod 755 install_openvino.sh
bash install_openvino.sh
```

Openvino will be installed in /opt/intel/openvino

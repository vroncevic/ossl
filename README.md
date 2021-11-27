<img align="right" src="https://raw.githubusercontent.com/vroncevic/ossl/dev/docs/ossl_logo.png" width="25%">

# Encrypting/Decrypting files

**ossl** is shell tool for operating openssl.

Developed in **[bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell))** code: **100%**.

[![ossl shell checker](https://github.com/vroncevic/ossl/workflows/ossl%20shell%20checker/badge.svg)](https://github.com/vroncevic/ossl/actions?query=workflow%3A%22ossl+shell+checker%22)

The README is used to introduce the tool and provide instructions on
how to install the tool, any machine dependencies it may have and any
other information that should be provided before the tool is installed.

[![GitHub issues open](https://img.shields.io/github/issues/vroncevic/ossl.svg)](https://github.com/vroncevic/ossl/issues) [![GitHub contributors](https://img.shields.io/github/contributors/vroncevic/ossl.svg)](https://github.com/vroncevic/ossl/graphs/contributors)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Installation](#installation)
- [Usage](#usage)
- [Dependencies](#dependencies)
- [Shell tool structure](#shell-tool-structure)
- [Docs](#docs)
- [Copyright and licence](#copyright-and-licence)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Installation

![Debian Linux OS](https://raw.githubusercontent.com/vroncevic/ossl/dev/docs/debtux.png)

Navigate to release **[page](https://github.com/vroncevic/ossl/releases)** download and extract release archive.

To install **ossl** type the following

```
tar xvzf ossl-x.y.tar.gz
cd ossl-x.y
cp -R ~/sh_tool/bin/   /root/scripts/ossl/ver.x.y/
cp -R ~/sh_tool/conf/  /root/scripts/ossl/ver.x.y/
cp -R ~/sh_tool/log/   /root/scripts/ossl/ver.x.y/
```

Self generated setup script and execution
```
./ossl_setup.sh 

[setup] installing App/Tool/Script ossl
	Sat 27 Nov 2021 08:07:11 PM CET
[setup] clean up App/Tool/Script structure
[setup] copy App/Tool/Script structure
[setup] remove github editor configuration files
[setup] set App/Tool/Script permission
[setup] create symbolic link of App/Tool/Script
[setup] done

/root/scripts/ossl/ver.2.0/
├── bin/
│   ├── center.sh
│   ├── decrypt.sh
│   ├── display_logo.sh
│   ├── encrypt.sh
│   └── ossl.sh
├── conf/
│   ├── ossl.cfg
│   ├── ossl.logo
│   └── ossl_util.cfg
└── log/
    └── ossl.log

3 directories, 9 files
lrwxrwxrwx 1 root root 38 Nov 27 20:07 /root/bin/ossl -> /root/scripts/ossl/ver.2.0/bin/ossl.sh
```

Or You can use docker to create image/container.

[![ossl docker checker](https://github.com/vroncevic/ossl/workflows/ossl%20docker%20checker/badge.svg)](https://github.com/vroncevic/ossl/actions?query=workflow%3A%22ossl+docker+checker%22)

### Usage

```
# Create symlink for shell tool
ln -s /root/scripts/ossl/ver.x.y/bin/ossl.sh /root/bin/ossl

# Setting PATH
export PATH=${PATH}:/root/bin/

# Encrypt file
ossl enc /opt/origin.txt
```

### Dependencies

**ossl** requires next modules and libraries
* sh_util [https://github.com/vroncevic/sh_util](https://github.com/vroncevic/sh_util)

### Shell tool structure

**ossl** is based on MOP.

Shell tool structure
```
sh_tool/
├── bin/
│   ├── center.sh
│   ├── decrypt.sh
│   ├── display_logo.sh
│   ├── encrypt.sh
│   └── ossl.sh
├── conf/
│   ├── ossl.cfg
│   ├── ossl.logo
│   └── ossl_util.cfg
└── log/
    └── ossl.log
```

### Docs

[![Documentation Status](https://readthedocs.org/projects/ossl/badge/?version=latest)](https://ossl.readthedocs.io/projects/ossl/en/latest/?badge=latest)

More documentation and info at
* [https://ossl.readthedocs.io/en/latest/](https://ossl.readthedocs.io/en/latest/)
* [https://www.gnu.org/software/bash/manual/](https://www.gnu.org/software/bash/manual/)

### Copyright and licence

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Copyright (C) 2016 by [vroncevic.github.io/ossl](https://vroncevic.github.io/ossl)

**ossl** is free software; you can redistribute it and/or modify
it under the same terms as Bash itself, either Bash version 4.2.47 or,
at your option, any later version of Bash 4 you may have available.

Lets help and support FSF.

[![Free Software Foundation](https://raw.githubusercontent.com/vroncevic/ossl/dev/docs/fsf-logo_1.png)](https://my.fsf.org/)

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://my.fsf.org/donate/)

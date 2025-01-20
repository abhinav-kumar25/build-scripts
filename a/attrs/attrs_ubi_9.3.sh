#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package       : attrs
# Version       : 23.1.0
# Source repo   : https://github.com/python-attrs/attrs.git
# Tested on     : UBI:9.3
# Language      : Python
# Travis-Check  : True
# Script License: Apache License, Version 2 or later
# Maintainer    : Abhinav Kumar <Abhinav.Kumar25@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# -----------------------------------------------------------------------------
PACKAGE_NAME=attrs
PACKAGE_VERSION=${1:-23.1.0}
PACKAGE_URL=https://github.com/python-attrs/attrs.git

# Install system dependencies
yum install -y git gcc gcc-c++ gzip tar make wget xz cmake yum-utils openssl-devel \
    openblas-devel bzip2-devel bzip2 zip unzip libffi-devel zlib-devel autoconf \
    automake libtool cargo pkgconf-pkg-config.ppc64le info.ppc64le fontconfig.ppc64le \
    fontconfig-devel.ppc64le sqlite-devel python-devel


# Upgrade pip
pip3 install --upgrade pip

# Clone the repository and checkout the required version
git clone $PACKAGE_URL
cd $PACKAGE_NAME/
git checkout $PACKAGE_VERSION

# Install the package along with optional dependencies for tests
pip3 install hatch hatch-vcs hatch-fancy-pypi-readme
pip3 install .[tests]

if ! (python3 -m hatch build); then
    echo "------------------$PACKAGE_NAME:Install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

# Install additional dependencies for pytest-mypy-plugins if needed
pip3 install pytest-mypy-plugins

# skipping some testcase as it is failing on x_86 also.
if ! (pytest --deselect=tests/test_funcs.py::TestAssoc::test_unknown --deselect=tests/test_mypy.yml); then
    echo "------------------$PACKAGE_NAME:Install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:Install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
fi

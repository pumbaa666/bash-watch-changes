#!/bin/bash

# https://github.com/recamshak/fswatch-docker/blob/master/Dockerfile

set -e

VERSION=1.14.0;

pushd /tmp;

sudo apt-get update -y;
sudo apt dist-upgrade;
sudo apt-get install -y build-essential; # install gcc and other compiling tools
url="https://github.com/emcrisostomo/fswatch/releases/download/$VERSION/fswatch-$VERSION.tar.gz"
echo "Downloading $url"
curl -O -J -L $url --output fswatch-$VERSION.tar.gz;
tar xzf fswatch-$VERSION.tar.gz;
cd fswatch-$VERSION;
./configure;
make;
sudo make install;
sudo ldconfig; # https://github.com/emcrisostomo/fswatch/issues/48

popd;
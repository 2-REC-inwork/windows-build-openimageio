#!/bin/bash

# Set correct directory/version
LIB_DIR=libiconv-1.16
ARCH=x64
BUILD_TYPE=Release


export ARCH
export BUILD_TYPE

INSTALL_PATH=$PWD/install/$ARCH/$BUILD_TYPE

export LIB_DIR
export INSTALL_PATH

PATH=/usr/local/mingw64/bin:$PATH
export PATH


if [ $BUILD_TYPE == 'Debug' ]
then
    DEBUG=-DDEBUG
else
    DEBUG=-DNDEBUG
fi
export DEBUG


cd $LIB_DIR

#TODO: add ARCH variable handling (to allow 32 bits build)
./configure --host=x86_64-w64-mingw32 --prefix=$INSTALL_PATH CC=x86_64-w64-mingw32-gcc CPPFLAGS="-I/usr/local/mingw64/include -Wall $DEBUG" LDFLAGS="-L/usr/local/mingw64/lib"

make
make check

make install

cd ..

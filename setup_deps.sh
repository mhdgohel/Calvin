#!/bin/bash
set -e

mkdir -p ext
cd ext
mkdir -p local

# libuuid
if [ ! -f "local/lib/libuuid.a" ]; then
    echo "Installing libuuid..."
    if [ ! -d "libuuid" ]; then
        wget https://sourceforge.net/projects/libuuid/files/libuuid-1.0.3.tar.gz/download -O libuuid-1.0.3.tar.gz
        tar xzf libuuid-1.0.3.tar.gz
        mv libuuid-1.0.3 libuuid
        rm libuuid-1.0.3.tar.gz
    fi
    cd libuuid
    ./configure --prefix=$PWD/../local
    make -j4
    make install
    cd ..
else
    echo "libuuid already exists."
fi

# Protobuf
if [ ! -f "local/bin/protoc" ]; then
    echo "Installing Protobuf..."
    if [ ! -d "protobuf" ]; then
        wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
        tar xzf protobuf-2.5.0.tar.gz
        mv protobuf-2.5.0 protobuf
        rm protobuf-2.5.0.tar.gz
    fi
    cd protobuf
    ./configure --prefix=$PWD/../local
    make -j4
    make install
    cd ..
else
    echo "Protobuf already exists."
fi

# ZeroMQ
if [ ! -f "local/lib/libzmq.a" ]; then
    echo "Installing ZeroMQ..."
    if [ ! -d "zeromq" ]; then
        wget https://download.zeromq.org/zeromq-2.1.11.tar.gz || wget https://archive.org/download/zeromq_2.1.11/zeromq-2.1.11.tar.gz
        tar xzf zeromq-2.1.11.tar.gz
        mv zeromq-2.1.11 zeromq
        rm zeromq-2.1.11.tar.gz
    fi
    cd zeromq
    # Point to local libuuid
    export CFLAGS="-I$PWD/../local/include"
    export CXXFLAGS="-I$PWD/../local/include"
    export LDFLAGS="-L$PWD/../local/lib"
    ./configure --prefix=$PWD/../local --without-libsodium
    make -j4
    make install
    cd ..
else
    echo "ZeroMQ already exists."
fi

# Zookeeper
if [ ! -d "zookeeper-3.4.14" ]; then
    echo "Installing Zookeeper..."
    wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
    tar xzf zookeeper-3.4.14.tar.gz
    rm zookeeper-3.4.14.tar.gz
else
    echo "Zookeeper already exists."
fi

# JDK
if [ ! -d "jdk-17.0.2" ]; then
    echo "Installing JDK..."
    wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz
    tar xzf openjdk-17.0.2_linux-x64_bin.tar.gz
    rm openjdk-17.0.2_linux-x64_bin.tar.gz
else
    echo "JDK already exists."
fi

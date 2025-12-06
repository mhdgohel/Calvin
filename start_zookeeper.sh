#!/bin/bash
# Start Zookeeper
export JAVA_HOME=$PWD/ext/jdk-17.0.2
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=$PWD/ext/zookeeper-3.4.14/zookeeper-3.4.14.jar:$PWD/ext/zookeeper-3.4.14/lib/*:$PWD/ext/zookeeper-3.4.14/conf
java -cp $CLASSPATH org.apache.zookeeper.server.quorum.QuorumPeerMain src_calvin/paxos/zookeeper.conf > zookeeper.log 2>&1 &
echo "Zookeeper started."

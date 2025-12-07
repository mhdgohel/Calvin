#!/bin/bash

# Trap to ensure cleanup happens on exit or interruption
cleanup() {
    echo "Restoring original configuration..."
    if [ -f "deploy-run.conf.bak" ]; then
        mv deploy-run.conf.bak deploy-run.conf
    fi
    pkill -f "bin/deployment/db"
    ext/zookeeper-3.4.14/bin/zkServer.sh stop $PWD/zoo.cfg
}
trap cleanup EXIT

# Kill any existing deployment processes safely
pkill -f "bin/deployment/db"
pkill -f "java.*zoo.cfg"

# Clean up previous logs
rm -f node_*.log zookeeper.out

# Set up environment
export JAVA_HOME=$PWD/ext/jdk-17.0.2
export PATH=$JAVA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$PWD/ext/local/lib:$PWD/ext/googletest/lib/.libs:$LD_LIBRARY_PATH

# Check if binaries exist
if [ ! -f "bin/deployment/db" ]; then
    echo "Error: bin/deployment/db not found. Please build the project first."
    exit 1
fi

# Backup existing config and swap in single node config
echo "Swapping configuration for single node benchmark..."
cp deploy-run.conf deploy-run.conf.bak
cp deploy-single.conf deploy-run.conf

# Create Zookeeper server config
cat > zoo.cfg <<EOF
tickTime=5000
initLimit=20
syncLimit=10
dataDir=/tmp/zookeeper
clientPort=2181
maxClientCnxns=500
EOF

# Start Zookeeper
echo "Starting Zookeeper..."
ext/zookeeper-3.4.14/bin/zkServer.sh start $PWD/zoo.cfg
sleep 5

echo "Starting single node (Node 0)..."

# Start node 0
export LD_LIBRARY_PATH=$PWD/ext/local/lib:$PWD/ext/googletest/lib/.libs:$LD_LIBRARY_PATH
bin/deployment/db 0 t 10 > node_0.log 2>&1 &

echo "Node started. Waiting for 200 seconds to gather data..."
sleep 200

echo "Stopping cluster..."
pkill -f "bin/deployment/db"

echo "Benchmarking Results (Throughput for Node 0):"
grep "Submitted" node_0.log | tail -n 5

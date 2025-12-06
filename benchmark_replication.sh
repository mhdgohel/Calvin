#!/bin/bash

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

# Create Zookeeper server config
cat > zoo.cfg <<EOF
tickTime=2000
dataDir=/tmp/zookeeper
clientPort=2181
EOF

# Start Zookeeper
echo "Starting Zookeeper..."
ext/zookeeper-3.4.14/bin/zkServer.sh start $PWD/zoo.cfg
sleep 5

echo "Starting 9 nodes (3 partitions, 3 replicas each)..."

# Start nodes 0-8
for i in {0..8}
do
    echo "Starting node $i..."
    # Run in background, redirect output to log file
    bin/deployment/db $i m 10 > node_$i.log 2>&1 &
    sleep 1
done

echo "Cluster started. Waiting for 40 seconds to gather data..."
sleep 40

echo "Stopping cluster..."
pkill -f "bin/deployment/db"

echo "Stopping Zookeeper..."
ext/zookeeper-3.4.14/bin/zkServer.sh stop $PWD/zoo.cfg

echo "Benchmarking Results (Throughput per Node):"
# Limit output to avoid crashing the agent
for i in {0..8}
do
    echo "Node $i:"
    grep "Submitted" node_$i.log | tail -n 5
done

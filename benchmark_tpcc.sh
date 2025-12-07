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
tickTime=20000
initLimit=20
syncLimit=10
dataDir=/tmp/zookeeper
clientPort=2181
maxClientCnxns=2000
EOF

# Start Zookeeper
echo "Starting Zookeeper..."
ext/zookeeper-3.4.14/bin/zkServer.sh start $PWD/zoo.cfg
sleep 10

echo "Starting 9 nodes (3 partitions, 3 replicas each)..."

# Start nodes 0-8 with staggered startup
for i in {0..8}
do
    echo "Starting node $i..."
    # Run in background, redirect output to log file
    export LD_LIBRARY_PATH=$PWD/ext/local/lib:$PWD/ext/googletest/lib/.libs:$LD_LIBRARY_PATH
    bin/deployment/db $i t 10 > node_$i.log 2>&1 &
    
    # Sleep 5s between nodes in same partition
    sleep 5
    
    # Sleep 20s between partitions (after node 2 and node 5)
    # if [ $i -eq 2 ] || [ $i -eq 5 ]; then
    #     echo "Partition started. Waiting 20s before starting next partition..."
    #     sleep 20
    # fi
done

echo "Cluster started. Waiting for 200 seconds to gather data..."
sleep 200

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

#!/bin/bash
set -e

# Export library path
export LD_LIBRARY_PATH=$PWD/ext/local/lib:$LD_LIBRARY_PATH
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"

# Run Node 0 (Leader)
./bin/deployment/db 0 m 0 > node0.log 2>&1 &
PID0=$!

# Run Node 1 (Follower)
./bin/deployment/db 1 m 0 > node1.log 2>&1 &
PID1=$!

# Run Node 2 (Follower)
./bin/deployment/db 2 m 0 > node2.log 2>&1 &
PID2=$!

echo "Running multi-cluster benchmark for 20 seconds..."
sleep 20

kill $PID0 $PID1 $PID2
wait $PID0 $PID1 $PID2 2>/dev/null || true

echo "Node 0 Output:"
grep "Submitted" node0.log | tail -n 5
echo "Node 1 Output:"
grep "Submitted" node1.log | tail -n 5
echo "Node 2 Output:"
grep "Submitted" node2.log | tail -n 5

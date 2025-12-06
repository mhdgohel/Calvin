#!/bin/bash
set -e

# Run 1 node, microbenchmark, 0% multipartition
export LD_LIBRARY_PATH=$PWD/ext/local/lib:$LD_LIBRARY_PATH
./bin/deployment/db 0 m 0 &
PID=$!

echo "Running benchmark for 10 seconds..."
sleep 10

kill $PID
wait $PID 2>/dev/null || true

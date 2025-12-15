# Calvin Codebase

This repository contains a modified version of the Calvin distributed database system, originally developed at Yale University. This version includes enhancements for fairness, fault tolerance (via Zookeeper/Paxos), and simplified benchmarking scripts.

## Benchmarking

To execute the TPC-C benchmark on this codebase, follow these steps:

### Prerequisites

1.  **Build the Project**: Ensure the project is built and the `bin/deployment/db` executable exists.
    ```bash
    cd src_calvin
    make -j
    cd ..
    ```
2.  **Dependencies**: Ensure all dependencies are installed. You can use the `setup_deps.sh` script if needed.

### Running the Benchmark

We have provided a script `benchmark_tpcc.sh` to automate the benchmarking process. This script sets up the environment, starts Zookeeper, launches the Calvin nodes, and collects results.

Run the benchmark with:

```bash
./benchmark_tpcc.sh
```

**What the script does:**
1.  **Cleanup**: Kills any existing `db` or `java` (Zookeeper) processes and removes old logs.
2.  **Environment Setup**: Exports necessary `JAVA_HOME` and `LD_LIBRARY_PATH`.
3.  **Zookeeper**: Creates a `zoo.cfg` and starts a local Zookeeper instance.
4.  **Node Startup**: Starts 9 Calvin nodes (Nodes 0-8) representing 3 partitions with 3 replicas each.
    *   Nodes are started with a delay between them to ensure stable startup.
5.  **Execution**: Runs the cluster for 200 seconds.
6.  **Teardown**: Stops all nodes and Zookeeper.
7.  **Results**: Parses the log files (`node_*.log`) and displays the throughput (Transactions per Second) for each node.

## Differences: `enchanced_calvin` vs `calvin_yale`

This codebase (`enchanced_calvin`) is a fork of the original `calvin_yale` codebase. Below are the key differences and improvements.

### 1. New Scripts and Tools

*   **`benchmark_tpcc.sh`**: Automated script for running the TPC-C benchmark on a 9-node cluster.
*   **`benchmark_replication.sh`**: Script focused on benchmarking replication scenarios.
*   **`setup_deps.sh`**: Helper script to set up dependencies.
*   **`start_zookeeper.sh`**: Utility to start Zookeeper independently.
*   **`calculate_throughput.py`**: Python script to parse logs and calculate throughput statistics.
*   **`src_calvin/paxos/paxos_test.cc`**: A new test file for verifying Paxos functionality.
*   **`src_calvin/deployment/replication.conf`**: Configuration file specifically for replication tests.

### 2. Key Code Changes

#### `src_calvin/deployment/main.cc`
*   **Sequencer Synchronization**: The `Sequencer` initialization now includes a new connection channel `"sequencer_sync"` to improve synchronization between sequencers.
*   **Logging**: Added `setbuf(stdout, NULL)` and additional `fprintf` calls for better real-time logging and debugging.
*   **Runtime**: Increased the execution spin time from 180 to 210 seconds to allow for longer benchmark runs.

#### `src_calvin/paxos/paxos.cc`
*   **Persistent ZNodes**: The `ZOO_EPHEMERAL` flag was removed from `zoo_acreate`. This means Zookeeper nodes created by Calvin are now **persistent** rather than ephemeral. This is a critical change for fault tolerance, ensuring data survives node restarts.
*   **CPU Optimization**: Added `usleep(1000)` in `GetNextBatchBlocking` to prevent tight loops from consuming 100% CPU while waiting for new batches.

#### `src_calvin/sequencer/sequencer.cc`
*   **Fairness Throttling**: Added an explicit `usleep(300000)` (300ms) in the main sequencer loop. This throttling is introduced to ensure fairness across all partitions by preventing any single node from overwhelming the system.
*   **Batch Retrieval**: Modified the non-Paxos batch retrieval logic to use `connection_->GetMessageBlocking` instead of a local queue, improving how batches are fetched from the leader.

### 3. Configuration Changes
*   **`src_calvin/deployment/deploy-run.conf`**: Updated configuration to reflect the current deployment environment.

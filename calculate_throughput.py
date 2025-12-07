import glob
import re

def calculate_throughput():
    print("Node | Average Txn/sec")
    print("---|---")
    
    log_files = sorted(glob.glob("node_*.log"))
    for log_file in log_files:
        node_id = log_file.split('_')[1].split('.')[0]
        total_txns = 0
        count = 0
        
        with open(log_file, 'r') as f:
            for line in f:
                match = re.search(r"Submitted (\d+) txns", line)
                if match:
                    total_txns += int(match.group(1))
                    count += 1
        
        if count > 0:
            avg_throughput = total_txns / count
            print(f"Node {node_id} | {avg_throughput:.2f}")
        else:
            print(f"Node {node_id} | No data")

if __name__ == "__main__":
    calculate_throughput()

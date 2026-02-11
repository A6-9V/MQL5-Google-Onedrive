import time
import requests
import sys

def benchmark(url, iterations=100):
    print(f"Benchmarking {url} with {iterations} iterations...")
    start_time = time.time()
    for _ in range(iterations):
        response = requests.get(url)
        if response.status_code != 200:
            print(f"Error: Status code {response.status_code}")
            sys.exit(1)
    end_time = time.time()
    avg_time = (end_time - start_time) / iterations
    print(f"Total time: {end_time - start_time:.4f}s")
    print(f"Average time per request: {avg_time*1000:.2f}ms")
    return avg_time

if __name__ == "__main__":
    benchmark("http://localhost:8080/health", 50)

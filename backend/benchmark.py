"""Benchmark AES murni, RSA murni, dan hybrid AES-GCM + RSA-OAEP."""

import argparse
import csv
import os
import time
from pathlib import Path

from cryptography.hazmat.primitives.ciphers.aead import AESGCM

from app.crypto.hybrid_file import encrypt_file
from app.crypto.keys import load_public_key, rsa_padding


DEFAULT_SIZES = (500 * 1024, 2 * 1024 * 1024, 10 * 1024 * 1024)
DEFAULT_ITERATIONS = 30
DEFAULT_WARMUP = 3
DEFAULT_RSA_ITERATIONS = 1
DEFAULT_RSA_WARMUP = 0
RSA_PUBLIC_KEY = load_public_key()
RSA_MAX_CHUNK = RSA_PUBLIC_KEY.key_size // 8 - (2 * 32) - 2


def encrypt_aes_only(data):
    """Encrypt file contents using AES-GCM without an RSA key envelope."""
    key = os.urandom(32)
    nonce = os.urandom(12)
    return nonce + AESGCM(key).encrypt(nonce, data, None)


def encrypt_rsa_only(data):
    """Encrypt the complete input with RSA-OAEP in RSA-sized chunks.

    RSA-2048 with OAEP-SHA256 accepts at most 190 bytes per operation.
    This is intentionally a benchmark-only implementation, not file storage.
    """
    return b"".join(
        RSA_PUBLIC_KEY.encrypt(data[offset:offset + RSA_MAX_CHUNK], rsa_padding())
        for offset in range(0, len(data), RSA_MAX_CHUNK)
    )


def benchmark(func, data, iterations=DEFAULT_ITERATIONS, warmup=DEFAULT_WARMUP):
    """Return average, minimum, and maximum duration in seconds."""
    for _ in range(warmup):
        func(data)

    durations = []
    for _ in range(iterations):
        start = time.perf_counter()
        func(data)
        durations.append(time.perf_counter() - start)
    return {
        "average_seconds": sum(durations) / len(durations),
        "minimum_seconds": min(durations),
        "maximum_seconds": max(durations),
    }


def make_test_file(path, size):
    """Create deterministic input data without keeping a second full copy in memory."""
    path.parent.mkdir(parents=True, exist_ok=True)
    pattern = bytes(range(256))
    with path.open("wb") as output:
        remaining = size
        while remaining:
            chunk_size = min(1024 * 1024, remaining)
            output.write((pattern * ((chunk_size // len(pattern)) + 1))[:chunk_size])
            remaining -= chunk_size


def format_size(size):
    if size % (1024 * 1024) == 0:
        return f"{size // (1024 * 1024)} MB"
    return f"{size // 1024} KB"


def run_benchmark(data_dir, output_csv, sizes, iterations, warmup, rsa_iterations, rsa_warmup):
    methods = (
        ("AES-GCM", encrypt_aes_only, iterations, warmup),
        ("RSA-OAEP only", encrypt_rsa_only, rsa_iterations, rsa_warmup),
        ("Hybrid AES-GCM + RSA-OAEP", encrypt_file, iterations, warmup),
    )
    results = []

    for size in sizes:
        input_path = data_dir / f"sample_{size}.bin"
        if not input_path.exists() or input_path.stat().st_size != size:
            make_test_file(input_path, size)
        data = input_path.read_bytes()

        for method_name, method, method_iterations, method_warmup in methods:
            timing = benchmark(method, data, method_iterations, method_warmup)
            result = {
                "file_size_bytes": size,
                "file_size": format_size(size),
                "method": method_name,
                "iterations": method_iterations,
                **timing,
            }
            results.append(result)
            print(
                f"{result['file_size']:>6} | {method_name:<24} | "
                f"avg {timing['average_seconds']:.6f}s | "
                f"min {timing['minimum_seconds']:.6f}s | "
                f"max {timing['maximum_seconds']:.6f}s"
            )

    output_csv.parent.mkdir(parents=True, exist_ok=True)
    with output_csv.open("w", newline="", encoding="utf-8") as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=results[0].keys())
        writer.writeheader()
        writer.writerows(results)
    print(f"\nHasil tersimpan di: {output_csv}")
    return results


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iterations", type=int, default=DEFAULT_ITERATIONS)
    parser.add_argument("--warmup", type=int, default=DEFAULT_WARMUP)
    parser.add_argument("--rsa-iterations", type=int, default=DEFAULT_RSA_ITERATIONS)
    parser.add_argument("--rsa-warmup", type=int, default=DEFAULT_RSA_WARMUP)
    parser.add_argument("--data-dir", type=Path, default=Path("benchmark_data"))
    parser.add_argument("--output", type=Path, default=Path("benchmark_results.csv"))
    return parser.parse_args()


if __name__ == "__main__":
    arguments = parse_args()
    if (
        arguments.iterations < 1
        or arguments.rsa_iterations < 1
        or arguments.warmup < 0
        or arguments.rsa_warmup < 0
    ):
        raise SystemExit("Jumlah iterasi minimal 1 dan warm-up tidak boleh negatif")
    run_benchmark(
        arguments.data_dir,
        arguments.output,
        DEFAULT_SIZES,
        arguments.iterations,
        arguments.warmup,
        arguments.rsa_iterations,
        arguments.rsa_warmup,
    )
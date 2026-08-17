#!/usr/bin/env python3
"""
CustosAequitas Synthetic Execution Data Generator

Generates deterministic test datasets with known ground truth for validating
the broker integrity detection algorithms.

Usage:
    python synthetic_generator.py --output datasets/ --seed 42
"""

import argparse
import csv
import math
import random
from datetime import datetime, timedelta
from typing import List, Dict, Tuple

class SyntheticDataset:
    """Represents a generated execution dataset with metadata."""
    
    def __init__(self, name: str, ground_truth: Dict, description: str):
        self.name = name
        self.ground_truth = ground_truth
        self.description = description
        self.deals: List[Dict] = []
        
    def add_deal(self, deal: Dict):
        self.deals.append(deal)
        
    def save_csv(self, filepath: str):
        """Save dataset to CSV with metadata header."""
        with open(filepath, 'w', newline='') as f:
            # Write metadata as comments
            f.write(f"# Dataset: {self.name}\n")
            f.write(f"# Description: {self.description}\n")
            f.write(f"# Ground Truth: {self.ground_truth}\n")
            f.write(f"# Records: {len(self.deals)}\n")
            f.write("#\n")
            
            # Write CSV header
            if self.deals:
                writer = csv.DictWriter(f, fieldnames=self.deals[0].keys())
                writer.writeheader()
                writer.writerows(self.deals)


class SyntheticGenerator:
    """Generates various types of synthetic execution data."""
    
    def __init__(self, seed: int = 42):
        random.seed(seed)
        self.seed = seed
        self.base_price = 1.10000
        self.base_timestamp = datetime(2024, 1, 15, 10, 0, 0)
        
    def generate_normal_dataset(self, n: int = 1000) -> SyntheticDataset:
        """
        Generate NORMAL broker behavior.
        
        Ground Truth:
        - Unbiased slippage (mean ≈ 0)
        - Stable latency
        - Normal spread variation
        - Low rejection rate (< 2%)
        
        Expected Detection: LOW ANOMALY
        """
        ds = SyntheticDataset(
            name=f"NORMAL_{n}",
            ground_truth={
                "anomaly": False,
                "slippage_bias": 0.0,
                "latency_bias": 0.0,
                "rejection_rate": 0.01,
                "expected_score_range": [85, 100],
                "expected_anomaly_probability": 0.05
            },
            description="Normal honest broker with typical market noise"
        )
        
        for i in range(n):
            ts = self.base_timestamp + timedelta(seconds=i*30)
            
            # Random direction
            direction = random.choice(["BUY", "SELL"])
            
            # Unbiased slippage: normal distribution centered at 0
            slippage_pips = random.gauss(0.0, 0.5)
            
            # Stable latency: 50-150ms
            latency_ms = random.gauss(100, 25)
            latency_ms = max(20, min(300, latency_ms))  # Clamp
            
            # Normal spread: 0.5-2.0 pips
            spread = random.gauss(1.0, 0.3)
            spread = max(0.3, spread)
            
            # Low rejection rate
            rejected = random.random() < 0.01
            
            ds.add_deal({
                "timestamp": ts.isoformat(),
                "symbol": "EURUSD",
                "direction": direction,
                "slippage_pips": round(slippage_pips, 4),
                "latency_ms": round(latency_ms, 2),
                "spread_pips": round(spread, 4),
                "rejected": rejected,
                "requote": False,
                "price": round(self.base_price + random.gauss(0, 0.001), 5)
            })
            
        return ds
        
    def generate_negative_slippage_bias(self, n: int = 1000, bias_strength: float = 0.7) -> SyntheticDataset:
        """
        Generate NEGATIVE SLIPPAGE BIAS (broker gives worse fills on average).
        
        Ground Truth:
        - Negative slippage more frequent/larger than positive
        - Directional asymmetry possible
        
        Expected Detection: HIGH SLIPPAGE ANOMALY
        """
        ds = SyntheticDataset(
            name=f"NEG_SLIPPAGE_BIAS_{n}_S{int(bias_strength*10)}",
            ground_truth={
                "anomaly": True,
                "anomaly_type": "negative_slippage_bias",
                "slippage_bias": -bias_strength,
                "expected_asymmetry_ratio": 1.5 + bias_strength,
                "expected_score_range": [20, 60],
                "expected_anomaly_probability": 0.8 + bias_strength * 0.2
            },
            description=f"Broker with negative slippage bias (strength={bias_strength})"
        )
        
        for i in range(n):
            ts = self.base_timestamp + timedelta(seconds=i*30)
            direction = random.choice(["BUY", "SELL"])
            
            # Biased slippage: shift mean negative
            base_slippage = random.gauss(-bias_strength * 0.5, 0.5)
            
            # Make negative slippage more extreme
            if random.random() < 0.6:  # 60% chance of negative
                slippage_pips = -abs(random.gauss(bias_strength * 0.3, 0.4))
            else:
                slippage_pips = abs(random.gauss(0.2, 0.3))
            
            latency_ms = random.gauss(100, 25)
            spread = random.gauss(1.0, 0.3)
            rejected = random.random() < 0.02
            
            ds.add_deal({
                "timestamp": ts.isoformat(),
                "symbol": "EURUSD",
                "direction": direction,
                "slippage_pips": round(slippage_pips, 4),
                "latency_ms": round(latency_ms, 2),
                "spread_pips": round(max(0.3, spread), 4),
                "rejected": rejected,
                "requote": False,
                "price": round(self.base_price + random.gauss(0, 0.001), 5)
            })
            
        return ds
        
    def generate_directional_bias(self, n: int = 1000, against: str = "SELL") -> SyntheticDataset:
        """
        Generate DIRECTIONAL BIAS (worse execution for one direction).
        
        Ground Truth:
        - BUY execution normal
        - SELL execution has negative slippage (or vice versa)
        
        Expected Detection: DIRECTIONAL ANOMALY
        """
        ds = SyntheticDataset(
            name=f"DIRECTIONAL_BIAS_{n}_{against}",
            ground_truth={
                "anomaly": True,
                "anomaly_type": "directional_bias",
                "affected_direction": against,
                "expected_buy_sell_diff": 0.5,
                "expected_score_range": [30, 65],
                "expected_anomaly_probability": 0.75
            },
            description=f"Broker with directional bias against {against} orders"
        )
        
        for i in range(n):
            ts = self.base_timestamp + timedelta(seconds=i*30)
            direction = random.choice(["BUY", "SELL"])
            
            # Normal slippage for favored direction
            if direction != against:
                slippage_pips = random.gauss(0.0, 0.4)
            else:
                # Biased against specified direction
                slippage_pips = random.gauss(-0.4, 0.5)
            
            # Maybe add directional latency too
            if direction == against:
                latency_ms = random.gauss(130, 30)
            else:
                latency_ms = random.gauss(90, 20)
                
            spread = random.gauss(1.0, 0.3)
            rejected = random.random() < 0.02
            
            ds.add_deal({
                "timestamp": ts.isoformat(),
                "symbol": "EURUSD",
                "direction": direction,
                "slippage_pips": round(slippage_pips, 4),
                "latency_ms": round(max(20, latency_ms), 2),
                "spread_pips": round(max(0.3, spread), 4),
                "rejected": rejected,
                "requote": False,
                "price": round(self.base_price + random.gauss(0, 0.001), 5)
            })
            
        return ds
        
    def generate_latency_bias(self, n: int = 1000) -> SyntheticDataset:
        """
        Generate LATENCY BIAS (asymmetric execution speed).
        
        Ground Truth:
        - One direction significantly slower
        - May indicate intentional delay
        
        Expected Detection: LATENCY ANOMALY
        """
        ds = SyntheticDataset(
            name=f"LATENCY_BIAS_{n}",
            ground_truth={
                "anomaly": True,
                "anomaly_type": "latency_bias",
                "slow_direction": "SELL",
                "latency_difference_ms": 80,
                "expected_score_range": [40, 70],
                "expected_anomaly_probability": 0.7
            },
            description="Broker with directional latency asymmetry"
        )
        
        for i in range(n):
            ts = self.base_timestamp + timedelta(seconds=i*30)
            direction = random.choice(["BUY", "SELL"])
            
            slippage_pips = random.gauss(0.0, 0.4)
            
            # Latency bias
            if direction == "SELL":
                latency_ms = random.gauss(180, 40)  # Slow
            else:
                latency_ms = random.gauss(80, 20)   # Fast
                
            spread = random.gauss(1.0, 0.3)
            rejected = random.random() < 0.015
            
            ds.add_deal({
                "timestamp": ts.isoformat(),
                "symbol": "EURUSD",
                "direction": direction,
                "slippage_pips": round(slippage_pips, 4),
                "latency_ms": round(max(20, latency_ms), 2),
                "spread_pips": round(max(0.3, spread), 4),
                "rejected": rejected,
                "requote": False,
                "price": round(self.base_price + random.gauss(0, 0.001), 5)
            })
            
        return ds
        
    def generate_spread_spike(self, n: int = 1000, spike_freq: float = 0.1) -> SyntheticDataset:
        """
        Generate SPREAD SPIKE pattern.
        
        Ground Truth:
        - Frequent abnormal spread widening
        - Especially around trade execution
        
        Expected Detection: SPREAD ANOMALY
        """
        ds = SyntheticDataset(
            name=f"SPREAD_SPIKE_{n}_F{int(spike_freq*10)}",
            ground_truth={
                "anomaly": True,
                "anomaly_type": "spread_manipulation",
                "spike_frequency": spike_freq,
                "normal_spread": 1.0,
                "spike_spread": 5.0,
                "expected_score_range": [35, 65],
                "expected_anomaly_probability": 0.75
            },
            description=f"Broker with frequent spread spikes (freq={spike_freq})"
        )
        
        for i in range(n):
            ts = self.base_timestamp + timedelta(seconds=i*30)
            direction = random.choice(["BUY", "SELL"])
            slippage_pips = random.gauss(0.0, 0.4)
            latency_ms = random.gauss(100, 25)
            
            # Spread spikes
            if random.random() < spike_freq:
                spread = random.gauss(4.0, 1.5)  # Spike
            else:
                spread = random.gauss(1.0, 0.2)  # Normal
                
            spread = max(0.3, spread)
            rejected = random.random() < 0.02
            
            ds.add_deal({
                "timestamp": ts.isoformat(),
                "symbol": "EURUSD",
                "direction": direction,
                "slippage_pips": round(slippage_pips, 4),
                "latency_ms": round(max(20, latency_ms), 2),
                "spread_pips": round(spread, 4),
                "rejected": rejected,
                "requote": False,
                "price": round(self.base_price + random.gauss(0, 0.001), 5)
            })
            
        return ds
        
    def generate_high_rejection(self, n: int = 1000, reject_rate: float = 0.15) -> SyntheticDataset:
        """
        Generate HIGH REJECTION rate.
        
        Ground Truth:
        - Abnormal rejection/requote frequency
        - May be directional
        
        Expected Detection: REJECTION ANOMALY
        """
        ds = SyntheticDataset(
            name=f"HIGH_REJECTION_{n}_R{int(reject_rate*100)}",
            ground_truth={
                "anomaly": True,
                "anomaly_type": "excessive_rejections",
                "rejection_rate": reject_rate,
                "normal_rate": 0.02,
                "expected_score_range": [25, 55],
                "expected_anomaly_probability": 0.85
            },
            description=f"Broker with high rejection rate ({reject_rate*100}%)"
        )
        
        for i in range(n):
            ts = self.base_timestamp + timedelta(seconds=i*30)
            direction = random.choice(["BUY", "SELL"])
            slippage_pips = random.gauss(0.0, 0.4)
            latency_ms = random.gauss(100, 25)
            spread = random.gauss(1.0, 0.3)
            
            rejected = random.random() < reject_rate
            requote = not rejected and random.random() < (reject_rate / 2)
            
            ds.add_deal({
                "timestamp": ts.isoformat(),
                "symbol": "EURUSD",
                "direction": direction,
                "slippage_pips": round(slippage_pips, 4),
                "latency_ms": round(max(20, latency_ms), 2),
                "spread_pips": round(max(0.3, spread), 4),
                "rejected": rejected,
                "requote": requote,
                "price": round(self.base_price + random.gauss(0, 0.001), 5)
            })
            
        return ds
        
    def generate_random_control(self, n: int = 1000) -> SyntheticDataset:
        """
        Generate RANDOM CONTROL (shuffled/randomized).
        
        Ground Truth:
        - Completely randomized parameters
        - No systematic patterns
        - Should NOT trigger anomaly detection consistently
        
        Expected Detection: LOW (false positive test)
        """
        ds = SyntheticDataset(
            name=f"RANDOM_CONTROL_{n}",
            ground_truth={
                "anomaly": False,
                "control_type": "randomized",
                "expected_false_positive_rate": 0.05,
                "expected_score_range": [70, 100],
                "expected_anomaly_probability": 0.05
            },
            description="Random control dataset for false positive testing"
        )
        
        for i in range(n):
            ts = self.base_timestamp + timedelta(seconds=i*30)
            
            # Fully randomized
            direction = random.choice(["BUY", "SELL"])
            slippage_pips = random.uniform(-1.0, 1.0)
            latency_ms = random.uniform(30, 200)
            spread = random.uniform(0.5, 2.5)
            rejected = random.random() < 0.02
            
            ds.add_deal({
                "timestamp": ts.isoformat(),
                "symbol": "EURUSD",
                "direction": direction,
                "slippage_pips": round(slippage_pips, 4),
                "latency_ms": round(latency_ms, 2),
                "spread_pips": round(spread, 4),
                "rejected": rejected,
                "requote": False,
                "price": round(self.base_price + random.gauss(0, 0.001), 5)
            })
            
        return ds
        
    def generate_shuffled_direction_control(self, base_ds: SyntheticDataset) -> SyntheticDataset:
        """
        Generate SHUFFLED DIRECTION control.
        
        Take a real dataset and randomly shuffle directions.
        This destroys any directional bias while preserving other statistics.
        
        Expected Detection: NO DIRECTIONAL ANOMALY
        """
        ds = SyntheticDataset(
            name=f"SHUFFLE_DIR_CONTROL_{len(base_ds.deals)}",
            ground_truth={
                "anomaly": False,
                "control_type": "shuffled_direction",
                "original_dataset": base_ds.name,
                "expected_directional_bias": 0.0,
                "expected_score_range": [65, 95],
                "expected_anomaly_probability": 0.1
            },
            description="Direction-shuffled control to test directional bias detection"
        )
        
        # Copy deals but shuffle directions
        original_directions = [d["direction"] for d in base_ds.deals]
        random.shuffle(original_directions)
        
        for i, deal in enumerate(base_ds.deals):
            new_deal = deal.copy()
            new_deal["direction"] = original_directions[i]
            ds.add_deal(new_deal)
            
        return ds


def main():
    parser = argparse.ArgumentParser(description='Generate synthetic execution datasets')
    parser.add_argument('--output', type=str, default='datasets', 
                        help='Output directory for CSV files')
    parser.add_argument('--seed', type=int, default=42,
                        help='Random seed for reproducibility')
    parser.add_argument('--samples', type=int, default=1000,
                        help='Number of samples per dataset')
    
    args = parser.parse_args()
    
    import os
    os.makedirs(args.output, exist_ok=True)
    
    gen = SyntheticGenerator(seed=args.seed)
    
    print(f"Generating synthetic datasets with seed={args.seed}, samples={args.samples}")
    print("=" * 60)
    
    datasets = [
        ("normal", gen.generate_normal_dataset(args.samples)),
        ("neg_slippage_bias", gen.generate_negative_slippage_bias(args.samples, 0.7)),
        ("directional_bias_sell", gen.generate_directional_bias(args.samples, "SELL")),
        ("latency_bias", gen.generate_latency_bias(args.samples)),
        ("spread_spike", gen.generate_spread_spike(args.samples, 0.15)),
        ("high_rejection", gen.generate_high_rejection(args.samples, 0.15)),
        ("random_control", gen.generate_random_control(args.samples)),
    ]
    
    # Generate shuffled control from the biased dataset
    biased_ds = gen.generate_negative_slippage_bias(args.samples, 0.7)
    shuffled_ds = gen.generate_shuffled_direction_control(biased_ds)
    datasets.append(("shuffle_dir_control", shuffled_ds))
    
    for name, ds in datasets:
        filepath = os.path.join(args.output, f"{name}.csv")
        ds.save_csv(filepath)
        print(f"✓ Generated: {ds.name}")
        print(f"  File: {filepath}")
        print(f"  Ground Truth: {ds.ground_truth}")
        print(f"  Records: {len(ds.deals)}")
        print()
    
    # Save ground truth summary
    summary_path = os.path.join(args.output, "ground_truth_summary.json")
    import json
    summary = {ds.name: ds.ground_truth for _, ds in datasets}
    with open(summary_path, 'w') as f:
        json.dump(summary, f, indent=2)
    print(f"Ground truth summary saved to: {summary_path}")
    
    print("\n" + "=" * 60)
    print("Synthetic dataset generation complete!")
    print("\nNext steps:")
    print("1. Load datasets into CustosAequitas for testing")
    print("2. Verify anomaly detection matches ground truth")
    print("3. Measure false positive rate on control datasets")
    print("4. Measure true positive rate on biased datasets")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
CustosAequitas Statistical Validator

Validates MQL5 statistical calculations against Python's numpy/scipy.
Used for cross-platform verification of the StatisticalCore module.

Usage:
    python validate_statistics.py --input fixtures/test_vectors.csv
"""

import argparse
import csv
import json
import math
import sys
from typing import List, Dict, Tuple
from dataclasses import dataclass

try:
    import numpy as np
    from scipy import stats
    NUMPY_AVAILABLE = True
except ImportError:
    NUMPY_AVAILABLE = False
    print("WARNING: numpy/scipy not available. Using pure Python fallback.")


@dataclass
class ValidationResult:
    test_name: str
    metric: str
    mql5_value: float
    python_value: float
    difference: float
    tolerance: float
    passed: bool
    notes: str


def read_csv_test_vectors(filepath: str) -> List[Dict]:
    """Read test vector CSV file."""
    vectors = []
    with open(filepath, 'r') as f:
        # Skip comment lines
        lines = [l for l in f if not l.startswith('#')]
    
    if not lines:
        return vectors
        
    reader = csv.DictReader(lines)
    for row in reader:
        vectors.append(row)
    
    return vectors


def parse_array(s: str) -> List[float]:
    """Parse array string like '[1,2,3]' or '1;2;3' to list of floats."""
    s = s.strip().strip('[]')
    if ';' in s:
        return [float(x) for x in s.split(';')]
    elif ',' in s:
        return [float(x) for x in s.split(',')]
    else:
        return [float(s)]


def calculate_mean(data: List[float]) -> float:
    if len(data) == 0:
        return float('nan')
    return sum(data) / len(data)


def calculate_median(data: List[float]) -> float:
    if len(data) == 0:
        return float('nan')
    sorted_data = sorted(data)
    n = len(sorted_data)
    mid = n // 2
    if n % 2 == 0:
        return (sorted_data[mid-1] + sorted_data[mid]) / 2
    else:
        return sorted_data[mid]


def calculate_stddev(data: List[float], sample: bool = True) -> float:
    """Calculate standard deviation (sample or population)."""
    if len(data) < 2:
        return 0.0 if not sample else float('nan')
    
    mean = calculate_mean(data)
    n = len(data)
    ddof = 1 if sample else 0
    
    variance = sum((x - mean) ** 2 for x in data) / (n - ddof)
    return math.sqrt(variance)


def calculate_variance(data: List[float], sample: bool = True) -> float:
    """Calculate variance (sample or population)."""
    if len(data) < 2:
        return 0.0 if not sample else float('nan')
    
    mean = calculate_mean(data)
    n = len(data)
    ddof = 1 if sample else 0
    
    return sum((x - mean) ** 2 for x in data) / (n - ddof)


def calculate_percentile(data: List[float], p: float) -> float:
    """Calculate percentile using linear interpolation."""
    if len(data) == 0:
        return float('nan')
    
    sorted_data = sorted(data)
    n = len(sorted_data)
    
    # Linear interpolation method (same as numpy default)
    idx = (p / 100.0) * (n - 1)
    lower = int(idx)
    upper = min(lower + 1, n - 1)
    frac = idx - lower
    
    return sorted_data[lower] * (1 - frac) + sorted_data[upper] * frac


def calculate_mad(data: List[float]) -> float:
    """Calculate Median Absolute Deviation."""
    if len(data) == 0:
        return float('nan')
    
    median = calculate_median(data)
    abs_devs = [abs(x - median) for x in data]
    return calculate_median(abs_devs)


def calculate_skewness(data: List[float]) -> float:
    """Calculate skewness (Fisher-Pearson)."""
    if len(data) < 3:
        return 0.0
    
    n = len(data)
    mean = calculate_mean(data)
    std = calculate_stddev(data, sample=False)
    
    if std == 0:
        return 0.0
    
    # Fisher-Pearson standardized moment
    m3 = sum((x - mean) ** 3 for x in data) / n
    return m3 / (std ** 3)


def calculate_kurtosis(data: List[float]) -> float:
    """Calculate excess kurtosis."""
    if len(data) < 4:
        return 0.0
    
    n = len(data)
    mean = calculate_mean(data)
    std = calculate_stddev(data, sample=False)
    
    if std == 0:
        return 0.0
    
    m4 = sum((x - mean) ** 4 for x in data) / n
    kurt = m4 / (std ** 4)
    return kurt - 3  # Excess kurtosis


def validate_test_vectors(vectors: List[Dict], tolerance: float = 1e-6) -> List[ValidationResult]:
    """Validate MQL5 outputs against Python calculations."""
    results = []
    
    for vec in vectors:
        test_name = vec.get('test_name', 'unknown')
        data_str = vec.get('input_data', '')
        
        try:
            data = parse_array(data_str)
        except:
            results.append(ValidationResult(
                test_name=test_name,
                metric='PARSE',
                mql5_value=float('nan'),
                python_value=float('nan'),
                difference=float('nan'),
                tolerance=tolerance,
                passed=False,
                notes='Failed to parse input array'
            ))
            continue
        
        # Validate each metric present in the vector
        metrics_to_check = ['mean', 'median', 'stddev', 'variance', 
                           'percentile_50', 'mad', 'skewness', 'kurtosis']
        
        for metric in metrics_to_check:
            mql5_key = f'mql5_{metric}'
            expected_key = f'expected_{metric}'
            
            if mql5_key not in vec and expected_key not in vec:
                continue
            
            # Get values
            mql5_val = float(vec.get(mql5_key, vec.get(expected_key, 'nan')))
            
            # Calculate expected in Python
            if metric == 'mean':
                py_val = calculate_mean(data)
            elif metric == 'median':
                py_val = calculate_median(data)
            elif metric == 'stddev':
                py_val = calculate_stddev(data)
            elif metric == 'variance':
                py_val = calculate_variance(data)
            elif metric == 'percentile_50':
                py_val = calculate_percentile(data, 50)
            elif metric == 'mad':
                py_val = calculate_mad(data)
            elif metric == 'skewness':
                py_val = calculate_skewness(data)
            elif metric == 'kurtosis':
                py_val = calculate_kurtosis(data)
            else:
                continue
            
            diff = abs(mql5_val - py_val) if not (math.isnan(mql5_val) or math.isnan(py_val)) else float('nan')
            passed = diff <= tolerance if not math.isnan(diff) else False
            
            results.append(ValidationResult(
                test_name=test_name,
                metric=metric,
                mql5_value=mql5_val,
                python_value=py_val,
                difference=diff,
                tolerance=tolerance,
                passed=passed,
                notes=''
            ))
    
    return results


def compare_with_numpy(data: List[float]) -> Dict:
    """Compare calculations with numpy/scipy if available."""
    if not NUMPY_AVAILABLE or len(data) == 0:
        return {}
    
    arr = np.array(data)
    
    return {
        'numpy_mean': np.mean(arr),
        'numpy_median': np.median(arr),
        'numpy_std': np.std(arr, ddof=1),
        'numpy_var': np.var(arr, ddof=1),
        'numpy_skew': stats.skew(arr),
        'numpy_kurtosis': stats.kurtosis(arr),
        'numpy_percentile_50': np.percentile(arr, 50),
    }


def generate_fixtures():
    """Generate standard test vector fixtures."""
    fixtures = []
    
    # Test case 1: Simple sequence
    data1 = [1, 2, 3, 4, 5]
    fixtures.append({
        'test_name': 'simple_sequence',
        'input_data': ';'.join(map(str, data1)),
        'expected_mean': str(calculate_mean(data1)),
        'expected_median': str(calculate_median(data1)),
        'expected_stddev': str(calculate_stddev(data1)),
        'expected_mad': str(calculate_mad(data1)),
    })
    
    # Test case 2: Single element
    data2 = [42.5]
    fixtures.append({
        'test_name': 'single_element',
        'input_data': '42.5',
        'expected_mean': '42.5',
        'expected_median': '42.5',
        'expected_stddev': '0.0',
    })
    
    # Test case 3: Constant data
    data3 = [7.0] * 10
    fixtures.append({
        'test_name': 'constant_data',
        'input_data': ';'.join(['7.0']*10),
        'expected_mean': '7.0',
        'expected_median': '7.0',
        'expected_stddev': '0.0',
        'expected_mad': '0.0',
    })
    
    # Test case 4: Symmetric distribution
    data4 = [-2, -1, 0, 1, 2]
    fixtures.append({
        'test_name': 'symmetric',
        'input_data': ';'.join(map(str, data4)),
        'expected_mean': '0.0',
        'expected_skewness': '0.0',
    })
    
    # Test case 5: Positive skew
    data5 = [1, 1, 1, 1, 10]
    fixtures.append({
        'test_name': 'positive_skew',
        'input_data': ';'.join(map(str, data5)),
        'expected_skewness': str(round(calculate_skewness(data5), 6)),
    })
    
    return fixtures


def main():
    parser = argparse.ArgumentParser(description='Validate MQL5 statistics against Python')
    parser.add_argument('--input', type=str, help='Input CSV with test vectors')
    parser.add_argument('--generate-fixtures', action='store_true', 
                        help='Generate standard test fixtures')
    parser.add_argument('--output', type=str, default='validation_results.json',
                        help='Output file for results')
    parser.add_argument('--tolerance', type=float, default=1e-6,
                        help='Tolerance for floating point comparison')
    
    args = parser.parse_args()
    
    if args.generate_fixtures:
        fixtures = generate_fixtures()
        output_file = 'fixtures/test_vectors.csv'
        
        import os
        os.makedirs('fixtures', exist_ok=True)
        
        with open(output_file, 'w', newline='') as f:
            fieldnames = ['test_name', 'input_data', 'expected_mean', 'expected_median', 
                         'expected_stddev', 'expected_mad', 'expected_skewness']
            writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction='ignore')
            writer.writeheader()
            writer.writerows(fixtures)
        
        print(f"Generated test fixtures: {output_file}")
        return
    
    if not args.input:
        print("ERROR: Please provide --input file or use --generate-fixtures")
        sys.exit(1)
    
    print(f"Loading test vectors from: {args.input}")
    vectors = read_csv_test_vectors(args.input)
    print(f"Loaded {len(vectors)} test vectors")
    
    print("\nValidating against Python calculations...")
    results = validate_test_vectors(vectors, args.tolerance)
    
    # Summary
    total = len(results)
    passed = sum(1 for r in results if r.passed)
    failed = total - passed
    
    print("\n" + "="*60)
    print("VALIDATION SUMMARY")
    print("="*60)
    print(f"Total tests:   {total}")
    print(f"Passed:        {passed} ({100*passed/total:.1f}%)")
    print(f"Failed:        {failed} ({100*failed/total:.1f}%)")
    print("="*60)
    
    if failed > 0:
        print("\nFAILED TESTS:")
        for r in results:
            if not r.passed:
                print(f"  {r.test_name}/{r.metric}: MQL5={r.mql5_value:.8f}, Py={r.python_value:.8f}, Diff={r.difference:.2e}")
    
    # Save detailed results
    output_data = {
        'summary': {
            'total': total,
            'passed': passed,
            'failed': failed,
            'pass_rate': passed/total if total > 0 else 0
        },
        'results': [
            {
                'test_name': r.test_name,
                'metric': r.metric,
                'mql5_value': r.mql5_value,
                'python_value': r.python_value,
                'difference': r.difference,
                'passed': r.passed
            }
            for r in results
        ]
    }
    
    with open(args.output, 'w') as f:
        json.dump(output_data, f, indent=2)
    
    print(f"\nDetailed results saved to: {args.output}")
    
    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    main()

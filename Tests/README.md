# CustosAequitas Test Suite Documentation

## Overview

This directory contains the complete testing infrastructure for CustosAequitas.

**Important:** MQL5 has limited native testing capabilities. This project uses a **hybrid approach**:
1. **MQL5 Test Harness** (`TestHarness.mq5`) - Runs inside MT5 terminal
2. **Python Validator** (`../Tools/PythonValidator/`) - External statistical validation
3. **Synthetic Data Generators** - Create known-answer test vectors

## Directory Structure

```
Tests/
├── README.md                    # This file
├── TestHarness.mq5              # Main executable test runner
├── Unit/                        # Unit tests for individual modules
│   └── README.md                # Test documentation
├── Integration/                 # Multi-module integration tests
│   └── README.md
├── Synthetic/                   # Synthetic data generation & ground-truth tests
│   ├── README.md
│   └── datasets/                # Generated CSV fixtures
├── NegativeControls/            # False-positive detection tests
│   └── README.md
├── Metamorphic/                 # Invariant-based tests
│   └── README.md
├── Regression/                  # Bug regression tests
│   └── README.md
└── Fixtures/                    # Pre-computed test vectors
    └── README.md
```

## Running Tests

### Prerequisites
- MetaTrader 5 Terminal
- MetaEditor (for compilation)
- Python 3.x (optional, for external validation)

### Method 1: MQL5 Test Harness (Primary)

1. Open `Tests/TestHarness.mq5` in MetaEditor
2. Compile (F7)
3. Run as Script on any chart
4. Check "Experts" tab for results
5. Results exported to `/Files/test_results_*.csv`

**What it tests:**
- StatisticalCore functions (mean, median, std dev, etc.)
- Property-based invariants
- Metamorphic transformations

### Method 2: Python External Validation (Secondary)

```bash
cd Tools/PythonValidator
python validate_statistics.py --input ../Tests/Fixtures/vectors.csv
```

**What it validates:**
- MQL5 statistical outputs against Python's scipy/numpy
- Cross-platform numerical consistency

## Test Categories

### Unit Tests
Test individual functions in isolation with known inputs/outputs.
- Edge cases (empty arrays, single element, extreme values)
- Normal cases
- Boundary conditions

### Integration Tests
Verify multiple modules work together correctly.
- SlippageEngine → AnomalyDetector → BrokerScorer pipeline
- Event flow from OnTradeTransaction to Report

### Synthetic Tests (CRITICAL)
Generate data with **known ground truth**:
- `NORMAL`: No anomaly expected
- `SLIPPAGE_BIAS`: Strong directional bias
- `LATENCY_BIAS`: Directional latency difference
- `SPREAD_SPIKE`: Controlled spread anomalies
- `RANDOM`: Pure noise (negative control)

### Negative Controls
Designed to produce **NO anomaly detection**:
- Shuffled timestamps
- Randomized directions
- Honest broker simulation
- High-volatility legitimate scenarios

**Purpose:** Measure false-positive rate

### Metamorphic Tests
Verify mathematical invariants:
- Translation invariance
- Scale transformation
- Permutation invariance
- Dataset duplication

### Regression Tests
Each discovered bug gets a regression test:
- REG-001: [Description]
- REG-002: [Description]

## Test Result Interpretation

### Passing Criteria
- All unit tests pass (100%)
- Negative controls show <5% false positive rate
- Synthetic biased datasets detected with >90% true positive rate
- Metamorphic invariants hold within tolerance

### Failure Modes
- **Unit test failure**: Implementation bug
- **Negative control failure**: Detector too sensitive (false positives)
- **Synthetic test failure**: Detector not sensitive enough (false negatives)
- **Metamorphic failure**: Mathematical error in implementation

## Adding New Tests

1. Add test function to `TestHarness.mq5` or create new `.mq5` script
2. Use `Assert()` helper for consistent reporting
3. Document expected behavior in corresponding `README.md`
4. For synthetic tests, define clear ground truth
5. Run full suite before committing

## Known Limitations

1. **No Mock Framework**: MQL5 lacks sophisticated mocking. Tests use direct function calls.
2. **Limited Parallelism**: Tests run sequentially in MT5
3. **Compilation Required**: Cannot run tests without MT5 terminal
4. **Floating Point Tolerance**: All comparisons use epsilon (1e-8 default)

## Evidence of Execution

After running tests, verify:
- Console output shows test summary
- CSV file generated in `/Files/` directory
- All assertions logged with PASS/FAIL status

**Do not claim tests passed without CSV evidence.**

## Next Steps

1. ✅ Unit tests implemented
2. ⏳ Generate synthetic datasets (run generator scripts)
3. ⏳ Execute negative controls
4. ⏳ Run metamorphic test suite
5. ⏳ Integrate Python validator
6. ⏳ Establish baseline metrics (FP/TP rates)

---

*Last Updated: Phase 2 Implementation*
*Test Framework Version: 2.0*

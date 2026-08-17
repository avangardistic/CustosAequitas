# 🛡️ CustosAequitas — Broker Integrity Sentinel

## *Execution Forensics & Statistical Anomaly Detection for MetaTrader 5*

---

## ⚠️ IMPORTANT DISCLAIMER

**CustosAequitas is a statistical analysis tool, NOT a manipulation detector.**

### What This Tool DOES:
- ✅ Collect execution data from your trading account
- ✅ Calculate slippage, latency, and spread statistics
- ✅ Identify **statistical anomalies** in execution patterns
- ✅ Generate reports with confidence intervals and sample sizes
- ✅ Provide evidence-based broker grading with uncertainty measures

### What This Tool Does NOT Do:
- ❌ Cannot see broker source code or internal systems
- ❌ Cannot prove intent or malicious behavior
- ❌ Cannot guarantee detection of all execution issues
- ❌ Cannot guarantee trading profits
- ❌ **Statistical anomalies ≠ proof of misconduct**

---

## 📖 For Non-Technical Users (Start Here!)

### What is CustosAequitas?

CustosAequitas (Latin: "Guardian of Equity") is an MQL5 Expert Advisor that monitors how your broker executes your trades. It collects data on:

- **Slippage**: The difference between expected and actual fill prices
- **Latency**: How long your orders take to execute
- **Spread**: The bid-ask spread during your trades
- **Requotes/Rejections**: How often orders are rejected or re-priced

Think of it as a "fitness tracker" for your broker's execution quality.

### What Do I Need?

1. **MetaTrader 5** platform installed
2. A **DEMO account** (recommended for initial testing)
3. Basic understanding of attaching EAs to charts
4. About 24-48 hours of monitoring time for meaningful data

### Quick Start Guide

#### Step 1: Install MetaTrader 5
Download from your broker or [metaquotes.net](https://www.metaquotes.net/en/metatrader5)

#### Step 2: Open a DEMO Account
**CRITICAL**: Always test on a demo account first! Active probing can result in real losses on live accounts.

#### Step 3: Install CustosAequitas
1. In MT5: File → Open Data Folder
2. Navigate to: `MQL5/Experts/`
3. Copy `CustosAequitas.mq5` to this folder
4. Copy all `.mqh` files to: `MQL5/Include/CustosAequitas/`
5. Restart MT5 or right-click Navigator → Refresh

#### Step 4: Compile the EA
1. Open MetaEditor (F4 in MT5)
2. Find `CustosAequitas.mq5` in the Navigator
3. Click Compile (F7)
4. Verify "0 errors" message

#### Step 5: Attach to Chart
1. Open EURUSD chart (recommended for testing)
2. Drag `CustosAequitas` from Navigator onto chart
3. In Parameters tab:
   - Set `InputEnableActiveProbing = false` (PASSIVE MODE)
   - Set `InputShowDashboard = true`
4. Click OK

#### Step 6: Enable Required Permissions
In the EA properties:
- ✅ Allow Algo Trading
- ✅ Allow Live Trading (for passive monitoring)
- ✅ Allow DLL imports (if required)

#### Step 7: Monitor the Dashboard
The dashboard shows:
- Current broker grade (A-F)
- Slippage statistics
- Latency metrics
- Sample size (number of trades observed)

#### Step 8: Review Reports
After collecting sufficient data (50+ trades):
- Press F1 to generate a manual report
- Check `MQL5/Files/CustosAequitas/Reports/` for HTML reports
- Review CSV data in `MQL5/Files/CustosAequitas/Data/`

#### Step 9: Interpret Results
See the "Understanding Your Results" section below.

#### Step 10: Take Action (If Needed)
- Grade A-B: Normal execution, continue trading
- Grade C: Monitor closely, consider reducing risk
- Grade D-F: Document evidence, consider broker alternatives

---

## 🎯 Operating Modes

### 🔵 PASSIVE MODE (Recommended for Beginners)
- **What it does**: Observes and records all trade executions
- **Risk level**: ZERO - No additional trades placed
- **Use case**: Initial assessment, ongoing monitoring
- **Settings**: `InputEnableActiveProbing = false`

### 🟡 CONTROLLED PROBE MODE (DEMO ONLY)
- **What it does**: Places micro test trades to measure execution
- **Risk level**: LOW on demo, HIGH on live
- **Use case**: Detailed forensics after passive observation
- **Settings**: `InputEnableActiveProbing = true` (DEMO ACCOUNTS ONLY)

### 🟢 DEFENSIVE HARDENING (Optional)
- **What it does**: Adjusts risk parameters based on broker grade
- **Risk level**: REDUCES risk when issues detected
- **Use case**: Protecting capital during suspicious periods
- **Settings**: `InputEnableHardening = true`

---

## 📊 Understanding Your Results

### Broker Grading System

| Grade | Score Range | Meaning | Recommended Action |
|-------|-------------|---------|-------------------|
| **A** | 90-100 | Excellent execution | Trade normally |
| **B** | 75-89 | Good, minor issues | Standard caution |
| **C** | 60-74 | Fair, moderate concerns | Reduce position sizes |
| **D** | 40-59 | Poor, significant problems | Consider broker change |
| **F** | 0-39 | Critical issues | Withdraw funds |

### Key Metrics Explained

#### Slippage Bias Ratio
- **Normal**: 0.8 - 1.2 (roughly equal positive/negative slippage)
- **Warning**: 1.2 - 1.8 (negative slippage occurring more often)
- **Danger**: > 1.8 (systematic negative slippage pattern)

#### Latency
- **Good**: < 50ms average
- **Acceptable**: 50-100ms
- **Concerning**: 100-200ms
- **Problematic**: > 200ms

#### Sample Size Requirements
- **< 30 trades**: Insufficient data, ignore results
- **30-50 trades**: Preliminary analysis only
- **50-100 trades**: Reliable preliminary grade
- **100+ trades**: High confidence assessment

---

## 🔧 Configuration Reference

### Essential Parameters

| Parameter | Default | Description | Safe Range |
|-----------|---------|-------------|------------|
| `InputEnablePassiveMonitoring` | true | Enable data collection | true/false |
| `InputEnableActiveProbing` | false | Place test trades | FALSE on live |
| `InputMinSampleSize` | 30 | Minimum samples for analysis | 20-50 |
| `InputShowDashboard` | true | Display live dashboard | true/false |

### Analysis Thresholds

| Parameter | Default | Description |
|-----------|---------|-------------|
| `InputSlippageWarningThreshold` | 1.5 | Bias ratio for warning |
| `InputSlippageDangerThreshold` | 1.8 | Bias ratio for danger |
| `InputLatencyWarnMs` | 100 | Latency warning (ms) |
| `InputLatencyDangerMs` | 200 | Latency danger (ms) |
| `InputRequoteWarnPercent` | 15.0 | Requote rate warning (%) |
| `InputRequoteDangerPercent` | 30.0 | Requote rate danger (%) |

### Advanced Settings

| Parameter | Default | Expert Notes |
|-----------|---------|--------------|
| `InputEnableFractalAnalysis` | true | Higuchi fractal dimension |
| `InputEnableEntropyAnalysis` | true | Permutation entropy |
| `InputConfidenceLevel` | 0.95 | Statistical confidence |
| `InputEnableHardening` | false | Keep false until validated |

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    MQL5 Terminal                         │
└───────────────────────┬─────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
    Market Data    Trade Events    Timer Events
        │               │               │
        └───────────────┼───────────────┘
                        │
              ┌─────────▼─────────┐
              │  Event Dispatcher │
              └─────────┬─────────┘
                        │
    ┌───────────────────┼───────────────────┐
    │                   │                   │
┌───▼────┐      ┌──────▼──────┐     ┌──────▼──────┐
│Spread  │      │  Slippage   │     │  Latency    │
│Forensic│      │   Engine    │     │  Profiler   │
└───┬────┘      └──────┬──────┘     └──────┬──────┘
    │                  │                   │
    └──────────────────┼───────────────────┘
                       │
             ┌─────────▼─────────┐
             │  Statistical Core │
             │  (Pure Functions) │
             └─────────┬─────────┘
                       │
          ┌────────────┼────────────┐
          │            │            │
    ┌─────▼─────┐ ┌───▼────┐ ┌─────▼─────┐
    │  Anomaly  │ │ Broker │ │ Hardening │
    │ Detector  │ │ Scorer │ │  Manager  │
    └─────┬─────┘ └───┬────┘ └─────┬─────┘
          │           │            │
          └───────────┼────────────┘
                      │
             ┌────────▼────────┐
             │ Report Generator│
             │   Dashboard     │
             └─────────────────┘
```

### Component Responsibilities

| Component | Purpose | Testable Independently |
|-----------|---------|----------------------|
| `Constants.mqh` | Shared definitions | N/A |
| `StatisticalCore.mqh` | Pure math functions | ✅ Yes |
| `SlippageEngine.mqh` | Slippage recording/analysis | ✅ Yes |
| `LatencyProfiler.mqh` | Latency measurement | ✅ Yes |
| `SpreadForensics.mqh` | Spread analysis | ✅ Yes |
| `RequoteAnalyzer.mqh` | Rejection tracking | ✅ Yes |
| `AnomalyDetector.mqh` | Pattern detection | ✅ Yes |
| `BrokerScorer.mqh` | Grade calculation | ✅ Yes |
| `HardeningManager.mqh` | Risk adjustment | ✅ Yes |
| `ReportGenerator.mqh` | Report generation | ✅ Yes |
| `Dashboard.mqh` | UI display | ❌ Requires terminal |

---

## 📈 Evidence Framework

### Observation → Evidence Hierarchy

```
RAW DATA
    ↓
STATISTICAL ANOMALY (p < 0.05)
    ↓
SIGNIFICANT DEVIATION (effect size > threshold)
    ↓
PERSISTENT PATTERN (repeated over time)
    ↓
DIRECTIONAL BIAS (asymmetric by direction)
    ↓
STRONG EVIDENCE (multiple indicators align)
    ↓
RECOMMENDATION (actionable conclusion)
```

### Confidence Levels

| Sample Size | Max Confidence | Interpretation |
|-------------|---------------|----------------|
| < 30 | 0.40 | Insufficient |
| 30-49 | 0.60 | Preliminary |
| 50-99 | 0.80 | Reliable |
| 100+ | 0.95 | High confidence |

---

## 🧪 Testing & Validation

### Synthetic Test Scenarios

The system should be validated against known scenarios:

1. **Honest Broker Simulation**: Random slippage, symmetric distribution
2. **Negative Slippage Bias**: Systematically worse fills
3. **Directional Latency**: BUY faster than SELL (or vice versa)
4. **Spread Spikes**: Abnormal widening before entries

### Metamorphic Tests

- Shuffling trade order should not change aggregate statistics
- Scaling all prices should not change normalized ratios
- Adding constant offset should not affect difference-based metrics

---

## ⚠️ Limitations & Caveats

### Known Limitations

1. **Historical vs Real Execution**: Strategy tester cannot perfectly replicate live execution
2. **Market Conditions**: Results vary by symbol, session, volatility regime
3. **Sample Size**: Small samples produce unreliable grades
4. **Causality**: Correlation ≠ causation; anomalies have multiple explanations
5. **MT5 Constraints**: Limited access to server-side timing information

### False Positive Sources

- News events causing legitimate spread widening
- Low liquidity periods (rollover, holidays)
- Network connectivity issues (client-side)
- Platform-specific delays
- Symbol-specific characteristics

---

## 📁 File Structure

```
CustosAequitas/
├── Experts/
│   └── CustosAequitas.mq5       # Main EA
├── Include/
│   └── CustosAequitas/
│       ├── Constants.mqh        # Shared definitions
│       ├── StatisticalCore.mqh  # Math functions
│       ├── SlippageEngine.mqh   # Slippage analysis
│       ├── LatencyProfiler.mqh  # Latency tracking
│       ├── SpreadForensics.mqh  # Spread analysis
│       ├── RequoteAnalyzer.mqh  # Rejection tracking
│       ├── AnomalyDetector.mqh  # Pattern detection
│       ├── BrokerScorer.mqh     # Grade calculation
│       ├── HardeningManager.mqh # Risk adjustment
│       ├── ReportGenerator.mqh  # Report generation
│       ├── Dashboard.mqh        # UI display
│       └── EventDispatcher.mqh  # Event routing
├── Data/                        # CSV exports
├── Reports/                     # HTML reports
├── Configs/                     # Preset configurations
└── Docs/                        # Documentation
```

---

## 📚 Research References

### Market Microstructure
- O'Hara, M. (1995). *Market Microstructure Theory*
- Harris, L. (2003). *Trading and Exchanges*

### Execution Quality
- Hasbrouck, J. (2007). *Empirical Market Microstructure*
- Kissell, R. (2013). *The Science of Algorithmic Trading*

### Statistical Methods
- Lehmann, E.L. (2005). *Testing Statistical Hypotheses*
- Good, P.I. (2013). *Permutation Tests*

---

## 🔒 Security & Privacy

- All data stored locally in `MQL5/Files/`
- No external network connections
- No credentials transmitted
- CSV/HTML reports contain no sensitive account data

---

## 🤝 Contributing

This is a research-oriented project. Contributions welcome in:
- Statistical methodology improvements
- Additional forensic tests
- Synthetic ground-truth testing
- Academic literature integration

---

## 📄 License

Open-source for research and educational purposes.

---

## 📞 Support

For issues, questions, or research collaboration:
- GitHub Issues: [avangardistic/CustosAequitas](https://github.com/avangardistic/CustosAequitas)

---

## 📋 Version Information

| Component | Version | Methodology |
|-----------|---------|-------------|
| CustosAequitas | 1.0.0 | v1.0.0 |

**Last Updated**: 2025

---

*Remember: CustosAequitas provides statistical evidence about execution patterns, not proof of misconduct. Always interpret results in context of market conditions, and never make decisions based solely on automated analysis.*

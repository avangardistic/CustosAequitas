# 🛡️ CustosAequitas - Broker Forensic Analysis & Adaptive Hardening System

**Version:** 1.0.0  
**License:** MIT  
**Platform:** MetaTrader 5 (MQL5)  

*"The code you write today protects the trades of tomorrow."*

---

## 📖 Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Usage](#usage)
6. [Dashboard](#dashboard)
7. [Reports](#reports)
8. [Broker Grading System](#broker-grading-system)
9. [Hardening Rules](#hardening-rules)
10. [API Reference](#api-reference)
11. [Troubleshooting](#troubleshooting)
12. [License](#license)

---

## 📋 Overview

**CustosAequitas** (Latin for "Guardian of Equity") is a comprehensive broker forensic analysis and adaptive hardening system for MetaTrader 5. It performs real-time analysis of broker execution quality, detects manipulation patterns, and automatically adjusts trading parameters to protect your capital.

### Key Capabilities

- **Slippage Analysis**: Tracks positive/negative slippage bias and magnitude ratios
- **Latency Profiling**: Measures execution latency with microsecond precision
- **Pattern Detection**: Uses fractal dimension and permutation entropy analysis
- **Manipulation Detection**: Identifies 6 types of broker manipulation
- **Adaptive Hardening**: Automatically adjusts risk based on broker behavior
- **Circuit Breaker**: Stops trading when danger conditions are detected
- **Professional Reports**: Generates HTML reports with actionable insights

---

## ✨ Features

### 🔍 Forensic Analysis

| Feature | Description |
|---------|-------------|
| Slippage Engine | Records every transaction with full metrics |
| Latency Profiler | Microsecond-precision timing measurements |
| Fractal Analysis | Higuchi algorithm for pattern complexity |
| Entropy Analysis | Permutation entropy for randomness detection |
| Session Breakdown | Separate statistics for Asian/London/NY sessions |

### 🎯 Manipulation Detection

Detects these manipulation types:

1. **MANIP_SLIPPAGE_BIAS** - Systematic negative slippage
2. **MANIP_LATENCY_SPIKE** - Artificial latency during volatility
3. **MANIP_REQUOTE_DELAY** - Strategic requoting patterns
4. **MANIP_STOP_HUNT** - Stop loss hunting behavior
5. **MANIP_SPREAD_WIDEN** - Abnormal spread widening
6. **MANIP_PRICE_FREEZE** - Price freeze during high impact news

### 🛡️ Adaptive Hardening

Automatically adjusts:

- Risk percentage per trade
- Stop loss distances
- Entry buffers
- Order types (Market vs Limit)
- Position sizes
- Session restrictions
- Maximum daily trades

### 📊 Broker Grading

| Grade | Score Range | Meaning |
|-------|-------------|---------|
| **A** | 90-100 | Excellent - No manipulation detected |
| **B** | 75-89 | Good - Minor issues |
| **C** | 60-74 | Fair - Moderate concerns |
| **D** | 45-59 | Poor - Significant problems |
| **E** | 30-44 | Very Poor - Severe manipulation |
| **F** | 0-29 | Fail - Critical manipulation |

---

## 📥 Installation

### Prerequisites

- MetaTrader 5 platform
- MQL5 compiler (build 2000+)
- Minimum account balance: $100

### Steps

1. Copy `CustosAequitas.mq5` to `MQL5/Experts/`
2. Copy all `.mqh` files to `MQL5/Include/CustosAequitas/`
3. Compile the EA in MetaEditor
4. Attach to any chart (recommended: EURUSD M1)

### File Structure

```
MQL5/
├── Experts/
│   └── CustosAequitas.mq5
├── Include/
│   ├── Constants.mqh
│   ├── SlippageEngine.mqh
│   ├── LatencyProfiler.mqh
│   ├── BrokerAnalyzer.mqh
│   ├── HardeningManager.mqh
│   └── ReportGenerator.mqh
└── Files/
    └── CustosAequitas/
        ├── Data/      (CSV exports)
        └── Reports/   (HTML reports)
```

---

## ⚙️ Configuration

### Test Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| InputTestBatchSize | 10 | Number of test trades per batch |
| InputTestVolume | 0.01 | Lot size for test trades |
| InputTestIntervalMin | 30 | Minutes between automatic tests |
| InputEnableAutoTest | true | Enable automatic testing |

### Report Settings

| Parameter | Default | Description |
|-----------|---------|-------------|
| InputAutoGenerateReport | true | Auto-generate HTML reports |
| InputReportThreshold | 50 | Min trades before report |
| InputExportCSV | true | Export data to CSV |

### Hardening Settings

| Parameter | Default | Description |
|-----------|---------|-------------|
| InputEnableHardening | true | Enable adaptive hardening |
| InputBaseRiskPercent | 2.0 | Base risk per trade (%) |
| InputShowDashboard | true | Show dashboard on chart |

### Advanced Settings

| Parameter | Default | Description |
|-----------|---------|-------------|
| InputMaxRecords | 5000 | Max records in memory |
| InputDashboardUpdateSec | 5 | Dashboard refresh rate |
| InputShowAlerts | true | Show alert messages |

---

## 🚀 Usage

### Basic Operation

1. **Attach EA** to any chart
2. **Wait for first test batch** (or press F2)
3. **Monitor dashboard** for broker grade
4. **Review reports** after sufficient data collection

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **F1** | Generate manual report |
| **F2** | Force test batch execution |
| **F3** | Toggle hardening on/off |

### Dashboard Buttons

- **📊 Generate Report (F1)** - Create HTML report immediately
- **🔍 Force Test (F2)** - Execute test batch now

---

## 📊 Dashboard

The dashboard displays:

```
┌─────────────────────────────────────┐
│ 🛡️ CUSTOSAEQUITAS v1.0.0           │
├─────────────────────────────────────┤
│ Grade: A                            │
│ Score: 95.3/100                     │
│ Risk: GREEN - Safe                  │
├─────────────────────────────────────┤
│ Avg Slippage: 0.5 pips              │
│ Bias Ratio: 1.02                    │
│ Avg Latency: 45 ms                  │
│ Spikes: 2                           │
├─────────────────────────────────────┤
│ Total Trades: 150                   │
│ ✓ Monitoring Active                 │
│ Next Test: 14:30:00                 │
└─────────────────────────────────────┘
```

### Color Coding

| Color | Meaning |
|-------|---------|
| 🟢 Green | Safe/Excellent |
| 🟡 Yellow | Warning/Caution |
| 🔴 Red | Danger/Stop |

---

## 📄 Reports

### HTML Report Sections

1. **Executive Summary** - Grade, score, risk level
2. **Slippage Analysis** - Detailed slippage metrics
3. **Latency Analysis** - Execution timing breakdown
4. **Forensic Analysis** - Pattern detection results
5. **Recommendations** - Actionable advice

### CSV Exports

Two CSV files are generated:

- `slippage_YYYY-MM-DD.csv` - All slippage records
- `latency_YYYY-MM-DD.csv` - All latency records

### Report Location

Reports are saved to:
```
MQL5/Files/CustosAequitas/Reports/
```

---

## 🎯 Broker Grading System

### Score Calculation

```
Overall Score = (Slippage Score × 0.4) + 
                (Latency Score × 0.4) + 
                (Pattern Score × 0.2)
```

### Slippage Score Factors

- Bias ratio (negative/positive trades)
- Magnitude ratio (avg neg/pos slippage)
- Average slippage in pips

### Latency Score Factors

- Average latency in milliseconds
- Spike frequency
- BUY/SELL asymmetry

### Pattern Score Factors

- Fractal dimension (Higuchi algorithm)
- Permutation entropy
- Price pattern randomness

---

## 🛡️ Hardening Rules

### Grade-Based Adjustments

| Grade | Risk Multiplier | Stop Buffer | Max Daily Trades |
|-------|-----------------|-------------|------------------|
| A | 100% | 5 pips | 50 |
| B | 90% | 5 pips | 40 |
| C | 70% | 6 pips | 25 |
| D | 50% | 7.5 pips | 15 |
| E | 30% | 10 pips | 5 |
| F | 10% | 10 pips | 0 |

### Risk Level Adjustments

| Risk Level | Additional Reduction |
|------------|---------------------|
| GREEN | None |
| YELLOW | 50% reduction |
| RED | 75% reduction + Circuit Breaker |

### Strategy Recommendations

| Grade | Recommended Strategy |
|-------|---------------------|
| A-B | All strategies (Scalping OK) |
| C | Day Trading & Swing |
| D | Swing Trading Only |
| E | Long-term Positions |
| F | No Trading Recommended |

---

## 📚 API Reference

### CSlippageEngine

```mql5
void AddSlippageRecord(datetime timestamp, string symbol, ...)
double CalculateBiasRatio()
double CalculateMagnitudeRatio()
double GetAverageSlippage()
STRUCT_SessionStats GetSessionStats(ENUM_SESSION session)
ENUM_RISK_LEVEL CalculateRiskLevel()
bool ExportToCSV(string filename)
```

### CLatencyProfiler

```mql5
void StartMeasurement(int operation_type)
void EndMeasurement(double price = 0)
double CalculateAverage()
int DetectSpikes(double multiplier = 2.0)
bool CheckAsymmetry(double threshold = 20.0)
ENUM_RISK_LEVEL GetStatus(int warn_ms, int danger_ms)
```

### CBrokerAnalyzer

```mql5
void SetSlippageEngine(CSlippageEngine* engine)
void SetLatencyProfiler(CLatencyProfiler* profiler)
STRUCT_BrokerProfile GenerateProfile()
ENUM_BROKER_GRADE CalculateBrokerGrade()
string[] GenerateRecommendations()
ENUM_MANIPULATION_TYPE[] DetectManipulations()
```

### CHardeningManager

```mql5
void UpdateBrokerProfile(STRUCT_BrokerProfile &profile)
double CalculateDynamicRisk(double base_risk)
double GenerateStopPlacement(double entry, bool is_buy)
bool ShouldEnterTrade()
string GetRecommendedStrategy()
```

### CReportGenerator

```mql5
void SetDataSources(CSlippageEngine*, CLatencyProfiler*, CBrokerAnalyzer*)
bool GenerateHTMLReport(string filename)
bool ExportCSVData(string prefix)
string GenerateSummaryText()
```

---

## 🔧 Troubleshooting

### Common Issues

**EA won't attach to chart**
- Ensure minimum balance ($100)
- Check symbol is tradeable
- Verify terminal connection

**No test trades executing**
- Check InputEnableAutoTest = true
- Verify market is open
- Check InputTestIntervalMin setting

**Reports not generating**
- Check folder permissions
- Ensure InputAutoGenerateReport = true
- Verify minimum trade count reached

**Circuit breaker activated**
- Review generated report
- Wait for risk level to normalize
- Consider changing brokers if persistent

### Error Codes

| Code | Meaning |
|------|---------|
| 1001 | Invalid account |
| 1002 | Invalid symbol |
| 1003 | Balance too low |
| 1004 | Connection lost |
| 1005 | Trading disabled |
| 1006 | Market closed |

---

## 📜 License

**MIT License**

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## 📞 Support

For questions, issues, or suggestions:

1. Check the dashboard for real-time status
2. Review generated HTML reports
3. Examine Experts tab for detailed logs
4. Analyze exported CSV data

---

## ⚠️ Disclaimer

This software is for educational and analytical purposes only. Past performance
does not guarantee future results. Trading forex and CFDs involves significant
risk of loss. Always test thoroughly on a demo account before live deployment.

The authors are not responsible for any financial losses incurred through the
use of this software. Users assume all risks associated with trading.

---

**Built with integrity for transparent markets.** 🛡️

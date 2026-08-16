# 🛡️ CustosAequitas - The Broker Integrity Sentinel

## *"In the shadow of every tick lies the truth of your broker"*

---

## 📌 Overview

**CustosAequitas** (Latin: "Guardian of Fairness") is an advanced MQL5 Expert Advisor that functions as both a **broker integrity auditor** and an **adaptive EA hardening system**. It employs multi-layered forensic analysis, chaos theory indicators, and behavioral profiling to:

1. **Detect Manipulation**: Identify stop-hunting, slippage bias, latency manipulation, and requote exploitation
2. **Grade Your Broker**: Provide an objective integrity score with actionable recommendations
3. **Harden Your EA**: Automatically adjust trading parameters to neutralize specific vulnerabilities
4. **Generate Evidence**: Create comprehensive reports documenting broker behavior

---

## 🔥 Key Features

### 🔬 Forensic Analysis
- **Fractal Complexity Analysis** - Distinguishes organic from synthetic price action
- **Permutation Entropy** - Measures pattern randomness vs algorithmic generation  
- **Slippage Asymmetry Detection** - Identifies directional bias in execution
- **Latency Profiling** - Measures round-trip execution times
- **Requote Analysis** - Tracks rejection patterns
- **Spread Forensics** - Monitors spread manipulation

### 📊 Real-Time Dashboard
- **Broker Grade**: A-F classification with color coding
- **Manipulation %**: Real-time manipulation likelihood
- **Status Indicators**: Latency, spread, slippage at-a-glance
- **Detection Alerts**: Instant notifications of suspicious behavior

### 🛡️ Adaptive Defense
- **Dynamic Entry Modulation**: Switch between market/limit/FOK orders
- **Stop-Loss Hardening**: Anti-hunt stop placement strategies
- **Position Sizing Adjustment**: Risk based on broker integrity
- **Strategy Rotation**: Unpredictable trading pattern

### 📈 Comprehensive Reporting
- **Detailed HTML Report**: Full forensic analysis
- **CSV Data Export**: Raw data for further analysis
- **Visual Dashboards**: At-a-glance interpretation
- **Actionable Recommendations**: Specific fixes for your EA

---

## 🚀 Quick Start

### Installation
1. Download `CustosAequitas.mq5` and all supporting `.mqh` files
2. Place `CustosAequitas.mq5` in `MQL5/Experts/` folder
3. Place all `.mqh` files in `MQL5/Include/` folder
4. Compile in MetaEditor (F7)
5. Attach to any chart
6. Review configuration parameters

### Basic Setup
```mql5
// Minimal configuration to get started
input int    TestBatchSize = 10;              // First test batch size
input double TestLots = 0.01;                 // Micro-transaction size
input int    TestIntervalMinutes = 60;        // How often to test
input bool   ShowLiveDashboard = true;        // Display status
```

### First Run
1. Start the EA on a demo account first
2. Allow 1-2 hours for initial data collection
3. Review the on-chart dashboard
4. After 24 hours, generate a full report
5. Follow recommendations for your live EA

---

## 📊 Understanding Your Results

### Broker Grades Explained

| Grade | Score | Meaning | Action |
|-------|-------|---------|--------|
| **A** | 90-100 | Direct Market Access, Honest Execution | Trade confidently with standard settings |
| **B** | 75-89 | Mostly Honest, Minor Issues | Use basic hardening strategies |
| **C** | 60-74 | Suspicious Behavior, Regular Manipulation | Full EA hardening required |
| **D** | 40-59 | Severe Manipulation, High Risk | Consider broker change, extreme caution |
| **F** | 0-39 | Highly Malicious, Active Exploitation | Stop trading immediately |

### Manipulation Types Detected

#### 🔴 Slippage Manipulation
- **Detection**: Negative/Positive slippage ratio > 1.8
- **Indicates**: Broker systematically fills losing orders worse
- **Solution**: Use limit orders, add buffer to market orders

#### 🔴 Latency Manipulation  
- **Detection**: Latency > 200ms or asymmetric BUY/SELL timing
- **Indicates**: Broker delays orders to your disadvantage
- **Solution**: Use VPS near broker, switch to limit orders

#### 🔴 Requote Manipulation
- **Detection**: Requote rate > 30% or directional bias
- **Indicates**: Broker rejects favorable fills
- **Solution**: Use FOK/IOC orders, reduce market orders

#### 🔴 Spread Manipulation
- **Detection**: Spread spikes before your entries
- **Indicates**: Broker tax on your trading style
- **Solution**: Add spread filters, trade during low-spread sessions

---

## 📁 Project Structure

```
CustosAequitas/
├── Experts/
│   └── CustosAequitas.mq5          # Main EA file
├── Include/
│   ├── BrokerAnalyzer.mqh          # Core analytics engine
│   ├── LatencyProfiler.mqh         # Latency measurement tools
│   ├── SlippageEngine.mqh          # Slippage analysis module
│   ├── HardeningManager.mqh        # Adaptive defense system
│   ├── ReportGenerator.mqh         # Reporting and visualization
│   └── Constants.mqh               # Global constants
├── Configs/
│   ├── config_forex.sample.ini     # Forex settings
│   ├── config_indices.sample.ini   # Indices settings
│   └── config_crypto.sample.ini    # Cryptocurrency settings
├── Reports/
│   └── (Generated HTML reports)
├── Data/
│   └── (Exported CSV files)
└── Docs/
    ├── README.md                   # This file
    ├── INSTALLATION.md             # Detailed setup guide
    ├── INTERPRETATION.md           # Results analysis guide
    └── TROUBLESHOOTING.md          # Common issues
```

---

## ⚙️ Configuration Deep Dive

### Essential Parameters

```mql5
// ==== Analysis Parameters ====

// Slippage - Adjust based on broker type
SlippageBiasThreshold = 1.2;     // Warning level (1.2-1.8)
SlippageDangerThreshold = 1.8;   // Danger level (>1.8)

// Latency - Adjust based on server location
LatencyWarnThreshold = 100;      // ms - warning
LatencyDangerThreshold = 200;    // ms - danger

// Requote - Adjust based on market conditions
RequoteWarnThreshold = 15;       // % - warning
RequoteDangerThreshold = 30;     // % - danger
```

### Hardening Settings

```mql5
// ==== Hardening Configuration ====
EnableAdaptiveSizing = true;      // Adjust risk based on broker
EnableStopHardening = true;       // Anti-hunt stop placement
EnableOrderTypeSwitching = true;  // Dynamic market/limit switching
MaxRiskPercentage = 2.0;          // % of account risk per trade
```

---

## 🔬 How It Works

### Phase 1: Passive Monitoring
The EA silently records all trading conditions without interfering:
- Tracks price movements and market microstructure
- Monitors spread behavior and requote patterns
- Builds baseline statistical profiles

### Phase 2: Active Probing
The EA executes controlled micro-transactions:
- Analyzes execution quality under controlled conditions
- Measures latency, slippage, and fill quality
- Compares BUY vs SELL execution parity

### Phase 3: Forensic Analysis
Advanced algorithms detect manipulation:
- **Fractal Analysis**: Identifies artificial price generation
- **Entropy Analysis**: Measures pattern randomness
- **Statistical Analysis**: Detects systematic biases

### Phase 4: Adaptive Response
Based on findings, the EA modifies behavior:
- Adjusts order types (market/limit/FOK)
- Modifies stop-loss placement strategies
- Changes position sizing and risk parameters

### Phase 5: Reporting
Comprehensive documentation generated:
- Executive summary with clear recommendations
- Detailed forensic analysis with visualizations
- Actionable steps for EA hardening

---

## ⚠️ Important Disclaimers

**No Guarantee of Detection**: While CustosAequitas provides sophisticated analysis, no external tool can guarantee detection of all manipulation methods without access to broker source code. Always combine with thorough due diligence.

**Legal Compliance**: This tool is for educational purposes and self-protection. Do not use for illegal purposes or to defame brokers. Always verify findings through multiple channels.

**Risk Warning**: Forex trading carries significant risk. Even with the best broker, trading losses are possible. This tool helps identify risks but cannot eliminate them.

**Technical Limitations**: MQL5 API limitations mean some advanced analysis (like full DOM analysis) may not be possible. Use this tool as one of multiple verification methods.

**Data Privacy**: All data stays on your local machine. No information is transmitted externally.

---

## 📝 Version History

**v1.0.0** - Initial Release (2026)
- Core forensic analysis suite
- Real-time dashboard
- Comprehensive HTML reporting
- Basic EA hardening features
- Configuration management

**Planned v1.1.0**:
- Machine learning-based detection
- Additional asset class support
- Enhanced reporting visualizations
- Cloud-based pattern sharing (optional)

---

## 📧 Support & Community

- **Documentation**: See `/Docs` folder for detailed guides
- **Issues**: Report bugs via GitHub Issues
- **Contributions**: Pull requests welcome

---

## 🏆 Acknowledgments

Special thanks to:
- MQL5 Community for technical guidance
- Forensic finance researchers for methodological foundations
- Professional traders who shared their experiences with broker manipulation

---

## 📜 License

This project is licensed under the MIT License.

**MIT License**  
Copyright (c) 2026 CustosAequitas Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

---

## 🙏 Final Word

*"In a world where execution is not guaranteed, the ability to verify is the ultimate protection."*

**CustosAequitas** empowers you with the tools to understand your broker's behavior, adapt your strategy accordingly, and trade with greater confidence and security.

---

**Version**: 1.0.0  
**Last Updated**: 2026

---

*Built with ❤️ for the trading community*

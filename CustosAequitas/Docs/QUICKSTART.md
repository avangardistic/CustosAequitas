# 🚀 CustosAequitas Quick Start Guide

## 1-Minute Setup

1. **Copy Files**
   - `Experts/CustosAequitas.mq5` → `MQL5/Experts/`
   - `Include/*.mqh` → `MQL5/Include/`

2. **Compile**
   - Open MetaEditor (F4)
   - Find CustosAequitas.mq5
   - Click Compile (F7)

3. **Attach to Chart**
   - Drag EA to EURUSD M1 chart
   - Enable AutoTrading button
   - Click OK on parameters

4. **Start Monitoring**
   - Dashboard appears immediately
   - First test runs after 30 minutes
   - Press F2 for immediate test

## Keyboard Shortcuts

- **F1** = Generate Report
- **F2** = Force Test Batch
- **F3** = Toggle Hardening

## What to Watch For

### Good Signs ✅
- Grade A or B
- Risk: GREEN
- Bias Ratio near 1.0
- Latency < 100ms

### Warning Signs ⚠️
- Grade C or lower
- Risk: YELLOW
- Bias Ratio > 1.5
- Latency spikes frequent

### Danger Signs 🚨
- Grade D, E, or F
- Risk: RED
- Circuit Breaker activated
- Consider changing broker

## Next Steps

1. Let EA run for 24 hours
2. Review generated HTML report
3. Check CSV data for patterns
4. Adjust parameters if needed

---
*For full documentation, see README.md*

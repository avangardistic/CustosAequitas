# 📦 CustosAequitas - Installation Guide

## *"Getting your broker integrity sentinel up and running"*

---

## 🖥️ System Requirements

### Minimum Requirements
- **MetaTrader 5**: Build 2245 or higher
- **Operating System**: Windows 7/10/11 or Wine (Linux/macOS)
- **RAM**: 512MB available memory
- **Disk Space**: 50MB for installation + space for data files
- **Internet Connection**: Required for live data feed

### Recommended Requirements
- **MetaTrader 5**: Latest build
- **VPS**: Located near broker's server (for accurate latency measurement)
- **RAM**: 1GB+ available memory
- **CPU**: Dual-core or better

---

## 📁 File Structure

After installation, your MQL5 folder should look like this:

```
MQL5/
├── Experts/
│   └── CustosAequitas.mq5          # Main EA file
├── Include/
│   ├── Constants.mqh               # Global constants
│   ├── BrokerAnalyzer.mqh          # Core analytics engine
│   ├── LatencyProfiler.mqh         # Latency measurement
│   ├── SlippageEngine.mqh          # Slippage analysis
│   ├── HardeningManager.mqh        # Adaptive defenses
│   └── ReportGenerator.mqh         # HTML report generation
├── Files/
│   └── CustosAequitas/
│       ├── Data/                   # CSV exports
│       └── Reports/                # HTML reports
└── Configs/                        # Configuration presets (optional)
```

---

## 🔧 Installation Steps

### Step 1: Locate Your MQL5 Data Folder

1. Open MetaTrader 5
2. Click **File** → **Open Data Folder**
3. This opens your MQL5 data directory

**Alternative Method:**
- Press `F1` in MetaEditor
- Search for "data folder"
- Note the path displayed

### Step 2: Copy EA File

1. Navigate to the `Experts` folder in your MQL5 directory
2. Copy `CustosAequitas.mq5` from the downloaded package
3. Paste it into the `Experts` folder
4. If a subfolder structure exists (e.g., `Experts/CustosAequitas/`), that's also acceptable

### Step 3: Copy Include Files

1. Navigate to the `Include` folder in your MQL5 directory
2. Create a subfolder named `CustosAequitas` (recommended) OR copy directly to `Include`
3. Copy all `.mqh` files:
   - `Constants.mqh`
   - `BrokerAnalyzer.mqh`
   - `LatencyProfiler.mqh`
   - `SlippageEngine.mqh`
   - `HardeningManager.mqh`
   - `ReportGenerator.mqh`

### Step 4: Compile the EA

1. Open **MetaEditor** (F4 from MT5 or Start Menu)
2. Navigate to **Experts** → **CustosAequitas.mq5**
3. Double-click to open the file
4. Press **F7** or click the **Compile** button
5. Verify compilation succeeds with no errors

**Expected Output:**
```
'CustosAequitas.mq5' compiled successfully
0 errors, 0 warnings
```

### Step 5: Attach to Chart

1. Return to MetaTrader 5
2. Open any chart (recommended: EURUSD or major pair)
3. In **Navigator** panel, expand **Expert Advisors**
4. Find **CustosAequitas**
5. Drag and drop onto the chart OR double-click
6. Enable **Allow Algo Trading** (top toolbar button)
7. Enable **AutoTrading** in Tools → Options → Expert Advisors

### Step 6: Configure Parameters

When the EA loads, you'll see the parameters dialog:

#### Essential Settings:
```
TestBatchSize = 10              # Trades per test batch
TestLots = 0.01                 # Micro-transaction size
TestIntervalMinutes = 60        # Test frequency
ShowLiveDashboard = true        # Display on-chart status
ExportCSV = true                # Save data to CSV
GenerateDetailedReport = true   # Enable HTML reports
```

#### Optional Advanced Settings:
```
SlippageBiasThreshold = 1.2     # Warning threshold
LatencyWarnThreshold = 100      # ms warning level
RequoteWarnThreshold = 15       # % warning level
EnableAdaptiveSizing = true     # Auto-adjust risk
EnableStopHardening = true      # Anti-hunt stops
```

Click **OK** to start monitoring.

---

## ✅ Verification Checklist

After installation, verify the following:

- [ ] EA compiles without errors
- [ ] Dashboard appears on chart within 10 seconds
- [ ] No error messages in Experts tab (Toolbox window)
- [ ] Journal shows "CustosAequitas initialized successfully"
- [ ] Live metrics update every 5 seconds
- [ ] CSV files created in `MQL5/Files/CustosAequitas/Data/`

---

## 🎯 First Run Procedure

### Phase 1: Demo Testing (Recommended)

**Day 1-2: Initial Data Collection**
1. Attach EA to demo account chart
2. Allow passive monitoring for 24-48 hours
3. Review dashboard metrics periodically
4. Check for any error messages

**Day 3: First Analysis**
1. Right-click chart → Expert Advisors → Generate Report
2. Review HTML report in `MQL5/Files/CustosAequitas/Reports/`
3. Note broker grade and manipulation indicators
4. Adjust hardening settings if needed

### Phase 2: Live Account Deployment

**Week 1: Cautious Monitoring**
1. Deploy on live account with minimum position size
2. Monitor execution quality closely
3. Compare demo vs live metrics
4. Document any discrepancies

**Week 2+: Full Deployment**
1. If metrics align with demo, enable full features
2. Implement recommended hardening strategies
3. Generate weekly integrity reports
4. Track broker behavior trends

---

## ⚙️ Configuration Presets

### Conservative Settings (Low Risk Tolerance)
```
TestBatchSize = 5
TestLots = 0.01
TestIntervalMinutes = 120
SlippageBiasThreshold = 1.1
LatencyWarnThreshold = 80
RequoteWarnThreshold = 10
EnableAdaptiveSizing = true
RiskPerTrade = 1.0
```

### Aggressive Settings (High Risk Tolerance)
```
TestBatchSize = 20
TestLots = 0.05
TestIntervalMinutes = 30
SlippageBiasThreshold = 1.5
LatencyWarnThreshold = 150
RequoteWarnThreshold = 25
EnableAdaptiveSizing = false
RiskPerTrade = 2.0
```

### News Trading Settings
```
TestBatchSize = 5
TestLots = 0.01
TestIntervalMinutes = 240
SlippageBiasThreshold = 2.0
LatencyWarnThreshold = 200
RequoteWarnThreshold = 40
EnableAdaptiveSizing = true
RiskPerTrade = 0.5
NewsFilterEnabled = true
```

---

## 🔍 Troubleshooting Installation Issues

### Issue: EA Not Appearing in Navigator

**Solution:**
1. Refresh Navigator (right-click → Refresh)
2. Restart MetaTrader 5
3. Verify file is in correct folder
4. Check file extension is `.mq5` not `.mq5.txt`

### Issue: Compilation Errors

**Common Errors:**

**Error: 'include file not found'**
- Verify all `.mqh` files are in `Include` folder
- Check include paths in source code
- Ensure case sensitivity matches (Windows is case-insensitive, but be consistent)

**Error: 'function already defined'**
- Multiple versions of same file
- Delete old versions from Include folder
- Clean and recompile

**Error: 'undefined identifier'**
- Missing include file
- Version mismatch between files
- Download complete package again

### Issue: Dashboard Not Displaying

**Solution:**
1. Check `ShowLiveDashboard` parameter is `true`
2. Verify chart has enough space
3. Try different chart timeframe
4. Check Experts log for errors
5. Reduce font size in parameters if chart is small

### Issue: No Data Being Collected

**Solution:**
1. Verify market is open (not weekend/holiday)
2. Check internet connection
3. Ensure symbol is actively trading
4. Verify `TestContinuousMode` is enabled
5. Check journal for connectivity errors

### Issue: CSV Files Not Created

**Solution:**
1. Verify `ExportCSV` parameter is `true`
2. Check folder permissions
3. Ensure sufficient disk space
4. Manually create `MQL5/Files/CustosAequitas/Data/` folder
5. Restart MetaTrader 5

---

## 🌐 Multi-Broker Setup

To monitor multiple brokers simultaneously:

### Method 1: Multiple MT5 Instances
1. Install separate MT5 installations for each broker
2. Install CustosAequitas on each instance
3. Configure unique `BrokerName` parameter
4. Compare reports across brokers

### Method 2: Multiple Charts (Same Broker, Different Accounts)
1. Open multiple charts in same MT5 instance
2. Attach EA to each chart
3. Set unique `BrokerName` for identification
4. Use different magic numbers if testing concurrently

---

## 📊 Data Management

### CSV Export Location
```
MQL5/Files/CustosAequitas/Data/
├── slippage_measurements.csv
├── latency_measurements.csv
├── requote_events.csv
├── spread_measurements.csv
└── broker_summary.csv
```

### HTML Report Location
```
MQL5/Files/CustosAequitas/Reports/
└── broker_integrity_report_YYYYMMDD_HHMMSS.html
```

### Data Retention Policy
- **Default**: CSV files accumulate indefinitely
- **Recommendation**: Archive monthly
- **Cleanup**: Delete CSV files older than 90 days
- **Backup**: Copy Reports folder to external storage

---

## 🔐 Security Considerations

### What Data Is Collected?
- Price data (publicly available)
- Execution timestamps
- Order fill prices
- Latency measurements
- Requote events

### What Data Is NOT Collected?
- Account balance
- Personal information
- Trading strategy details
- Position sizes (except test orders)

### Data Privacy
- All data stored locally
- No external transmission
- No cloud synchronization
- No third-party access

---

## 🆘 Getting Help

### Before Contacting Support

1. **Check Documentation**: Review README.md and INTERPRETATION.md
2. **Review Logs**: Check Experts and Journal tabs
3. **Search Issues**: GitHub Issues may have solution
4. **Try Safe Mode**: Disable advanced features temporarily

### When Contacting Support

Provide the following:
- MT5 build number
- Broker name
- Symbol being tested
- Screenshot of error
- Relevant log excerpts
- Steps to reproduce issue

### Support Channels
- **GitHub Issues**: For bug reports
- **Discord Community**: For general questions
- **Documentation**: For how-to guides

---

## 🔄 Updates & Upgrades

### Checking for Updates
1. Visit GitHub repository
2. Compare version numbers
3. Review changelog for new features

### Updating Process
1. Backup current files
2. Download new version
3. Replace existing files
4. Recompile EA
5. Test on demo first

### Backward Compatibility
- Configuration files remain compatible
- Historical data preserved
- Reports maintain format

---

## 📝 Uninstallation

### Complete Removal
1. Remove EA from all charts
2. Delete `CustosAequitas.mq5` from Experts folder
3. Delete all `.mqh` files from Include folder
4. Delete `MQL5/Files/CustosAequitas/` folder
5. Restart MetaTrader 5

### Partial Removal (Keep Data)
1. Remove EA from all charts
2. Delete EA and include files only
3. Preserve Files/CustosAequitas/ folder for records

---

## ✅ Post-Installation Checklist

After completing installation:

- [ ] EA compiles successfully
- [ ] Dashboard displays on chart
- [ ] Metrics update in real-time
- [ ] CSV files are created
- [ ] No errors in Journal/Experts logs
- [ ] Test batch executes (if enabled)
- [ ] Report generation works
- [ ] Alert notifications function
- [ ] Parameters can be modified
- [ ] EA survives MT5 restart

---

**Installation Complete!** 🎉

Your broker integrity sentinel is now active and monitoring execution quality.

For next steps, see **INTERPRETATION.md** to understand your results.

---

*Last Updated: August 2026*  
*Version: 1.0.0*

# 🔧 CustosAequitas - Troubleshooting Guide

## *"Solving common issues and edge cases"*

---

## 🚨 Critical Issues

### Issue: EA Stops Working After News Event

**Symptoms:**
- Dashboard freezes
- No new data collection
- Error messages in Journal

**Possible Causes:**
1. Broker halted trading during news
2. Extreme spread triggered safety circuit
3. Margin call or account restriction

**Solutions:**
```
1. Check if market is open (wait for session restart)
2. Review Journal for "Trade context busy" errors
3. Verify account has sufficient margin
4. Remove EA and reattach after market stabilizes
5. Check if broker imposed trading restrictions
```

**Prevention:**
- Enable news filter in parameters
- Set wider spread thresholds during high-impact events
- Use VPS with reliable connectivity

---

### Issue: Circuit Breaker Triggered

**Symptoms:**
- EA enters "SAFE_MODE"
- Trading disabled automatically
- Red alert on dashboard

**Trigger Conditions:**
- 3+ severe manipulation signals within 1 hour
- Broker grade drops to F
- Latency exceeds 500ms repeatedly
- Requote rate > 70%

**Solutions:**
```
1. DO NOT override circuit breaker immediately
2. Review detection log for specific triggers
3. Wait 30 minutes for conditions to normalize
4. If persistent, withdraw funds and change broker
5. Document evidence for regulatory complaint
```

**Reset Procedure:**
```
1. Right-click chart → Expert Advisors → Properties
2. Set "EnableGracefulDegradation" to false temporarily
3. Click OK, then re-enable to true
4. Monitor closely for recurring issues
```

---

### Issue: Test Orders Not Executing

**Symptoms:**
- Test batch shows 0 trades executed
- Journal shows order rejection errors
- Dashboard shows "Testing paused"

**Possible Causes:**
1. Insufficient account balance
2. Broker minimum lot size > 0.01
3. Market closed (weekend/holiday)
4. Symbol not allowed for algorithmic trading

**Solutions:**
```
1. Verify account balance > $100 for micro lots
2. Check symbol specifications (minimum lot size)
3. Ensure market is open (weekday, active session)
4. Confirm "Allow Algo Trading" enabled in MT5
5. Try different symbol (EURUSD recommended)
```

**Debug Steps:**
```journal
Check Experts tab for:
- "Invalid volume" → Adjust TestLots parameter
- "Market closed" → Wait for session open
- "Not enough money" → Reduce position size
- "Trade disabled" → Enable auto-trading in MT5
```

---

## ⚠️ Common Warnings

### Warning: "Slippage Data Insufficient"

**Meaning:** Less than 30 samples collected

**Solutions:**
```
1. Allow more time for data collection (24-48 hours)
2. Increase trade frequency if using own strategy
3. Enable TestContinuousMode for active probing
4. Reduce SlippageBiasThreshold temporarily
```

**Expected Timeline:**
- 30 samples: ~4-6 hours (active trading)
- 50 samples: ~12-24 hours
- 100+ samples: 2-3 days for statistical significance

---

### Warning: "Latency Baseline Unstable"

**Meaning:** Latency variance too high for reliable baseline

**Causes:**
1. Network connectivity issues
2. VPS overloaded
3. Broker server maintenance
4. Internet service provider problems

**Solutions:**
```
1. Run network speed test
2. Restart MT5 platform
3. Contact VPS provider if using VPS
4. Check broker server status page
5. Try different internet connection
```

**Target Metrics:**
- Standard deviation < 20ms (stable)
- Standard deviation 20-50ms (acceptable)
- Standard deviation > 50ms (investigate cause)

---

### Warning: "Spread Anomaly Detected"

**Meaning:** Spread deviates significantly from historical average

**Scenarios:**

**Legitimate Causes:**
- Major news event
- Session transition (rollover)
- Holiday/thin liquidity
- Market opening/closing

**Suspicious Causes:**
- Spread spike before EA entry signal
- Targeted widening on specific symbol
- Pattern correlates with position direction

**Actions:**
```
1. Check economic calendar for news events
2. Verify time of day (avoid 21:00-22:00 GMT rollover)
3. Compare with other brokers' spreads
4. If suspicious, document timestamp and pattern
5. Add spread filter to avoid anomalous periods
```

---

## 📊 Dashboard Issues

### Issue: Dashboard Not Displaying

**Symptoms:**
- Chart shows only candles
- No CustosAequitas panel visible
- EA appears attached but no visual output

**Solutions:**
```
1. Verify ShowLiveDashboard = true in parameters
2. Check chart has enough space (zoom out)
3. Try different timeframe (H1 recommended)
4. Reduce font size in advanced settings
5. Delete all objects and restart EA
```

**Manual Reset:**
```
1. Right-click chart → Object List
2. Select all objects starting with "CA_"
3. Delete selected objects
4. Remove EA from chart
5. Reattach EA with default settings
```

---

### Issue: Dashboard Shows Incorrect Data

**Symptoms:**
- Metrics don't match recent trades
- Counts seem too high/low
- Timestamps incorrect

**Possible Causes:**
1. Multiple EA instances on same account
2. Corrupted data files
3. Clock synchronization issue
4. Magic number conflict

**Solutions:**
```
1. Ensure only one CustosAequitas instance per symbol
2. Clear CSV files in Data folder
3. Synchronize computer clock with internet time
4. Change MagicTestOrders to unique value
5. Restart MT5 completely
```

---

### Issue: Alerts Not Triggering

**Symptoms:**
- Severe manipulation detected but no alert
- Sound notifications silent
- Email/push notifications not received

**Solutions:**
```
1. Tools → Options → Events → Enable "Expert Advisors"
2. Tools → Options → Notifications → Configure email/push
3. Verify sound files exist in Sounds folder
4. Check Windows volume mixer for MT5
5. Test alert system manually
```

**Alert Configuration:**
```mql5
// In EA parameters:
EnableSoundAlerts = true
EnableEmailAlerts = true
EnablePushAlerts = true
AlertThreshold = WARNING  // or DANGER for critical only
```

---

## 📁 File System Issues

### Issue: CSV Files Not Created

**Symptoms:**
- ExportCSV = true but no files appear
- Data folder empty
- Journal shows file I/O errors

**Solutions:**
```
1. Manually create folder: MQL5/Files/CustosAequitas/Data/
2. Check folder permissions (read/write access)
3. Verify sufficient disk space
4. Disable antivirus temporarily (may block file creation)
5. Restart MT5 with administrator privileges
```

**File Path Verification:**
```
Correct path: C:\Users\[Username]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\Files\CustosAequitas\Data\

To find your path:
1. MT5 → File → Open Data Folder
2. Navigate to Files → CustosAequitas → Data
```

---

### Issue: HTML Report Generation Fails

**Symptoms:**
- Report button does nothing
- Empty HTML file created
- Journal shows template errors

**Solutions:**
```
1. Verify GenerateDetailedReport = true
2. Check Reports folder exists and writable
3. Ensure minimum 50 samples collected
4. Try manual report generation via context menu
5. Check disk space for report file
```

**Manual Report Generation:**
```
1. Right-click chart → Expert Advisors
2. Select "Generate Integrity Report"
3. Wait for confirmation message
4. Navigate to Reports folder
5. Open HTML file in browser
```

---

### Issue: Configuration Files Not Loading

**Symptoms:**
- Preset configurations ignored
- Parameters revert to defaults
- .ini files not recognized

**Solutions:**
```
1. Verify .ini files in correct folder (MQL5/Configs/)
2. Check file extension is .ini not .ini.txt
3. Ensure proper INI format (key=value pairs)
4. Load preset manually via EA properties
5. Save current settings as new preset
```

**INI File Format:**
```ini
[Settings]
TestBatchSize=10
TestLots=0.01
TestIntervalMinutes=60
ShowLiveDashboard=true
ExportCSV=true
```

---

## 🔬 Analysis Accuracy Issues

### Issue: Fractal Dimension Seems Incorrect

**Symptoms:**
- H value near 1.0 during volatile market
- Manipulation % seems exaggerated
- Doesn't match visual price action

**Possible Causes:**
1. Insufficient data points (< 100 ticks)
2. Extremely low volatility period
3. Calculation window too short
4. Symbol characteristics (exotic pairs differ)

**Solutions:**
```
1. Increase data collection period
2. Use major pairs (EURUSD, GBPUSD) for calibration
3. Adjust Higuchi K-max parameter (default: 10)
4. Compare with benchmark values for same symbol
5. Consider session timing (avoid low liquidity)
```

**Expected Ranges by Symbol:**
| Symbol | Normal H Range |
|--------|----------------|
| EURUSD | 0.55 - 0.75 |
| GBPUSD | 0.50 - 0.70 |
| USDJPY | 0.58 - 0.78 |
| Gold   | 0.45 - 0.65 |
| Exotics| 0.40 - 0.60 |

---

### Issue: Entropy Calculation Anomalies

**Symptoms:**
- Entropy > 1.0 (impossible)
- Entropy = 0 (constant price)
- Wild fluctuations between calculations

**Causes:**
1. Data corruption in tick history
2. Symbol has fixed/frozen price
3. Calculation parameters misconfigured
4. Broker providing artificial prices

**Solutions:**
```
1. Refresh chart data (right-click → Refresh)
2. Verify symbol is actively trading
3. Check embedding dimension (default: 3)
4. Compare entropy across multiple symbols
5. Contact broker if price feed suspicious
```

---

### Issue: Stop-Loss Detection False Positives

**Symptoms:**
- Stop-hunting flagged during normal volatility
- High hit ratio during news events
- Pattern detected on single occurrence

**Context Matters:**
Stop-loss hunting detection requires context:
- Was there a major news event?
- Did price reverse immediately after?
- Are round numbers involved?
- Multiple accounts affected?

**Refinement:**
```
1. Increase minimum sample size (default: 50)
2. Enable news filter to exclude events
3. Require pattern repetition (3+ occurrences)
4. Cross-validate with other manipulation indicators
5. Manual review before taking action
```

---

## 🌐 Connectivity Issues

### Issue: Frequent Disconnections

**Symptoms:**
- "No connection" errors in Journal
- Data gaps in analysis
- Test batches interrupted

**Solutions:**
```
1. Check internet connection stability
2. Use wired connection instead of WiFi
3. Contact VPS provider if applicable
4. Try different DNS servers (8.8.8.8, 1.1.1.1)
5. Contact broker about server issues
```

**Connection Quality Test:**
```
Command Prompt:
ping [broker-server].com -t

Monitor for:
- Packet loss > 1% (problematic)
- Latency spikes > 200ms
- Timeout errors
```

---

### Issue: Time Synchronization Errors

**Symptoms:**
- Timestamps don't match local time
- Session detection incorrect
- Report timestamps wrong

**Solutions:**
```
1. Tools → Options → Server → Enable auto-sync
2. Windows: Right-click clock → Adjust date/time
3. Enable "Set time automatically" in Windows
4. Sync with time.nist.gov
5. Restart MT5 after synchronization
```

**GMT Offset Configuration:**
```
Broker uses GMT+2 in summer:
- Set SessionOffset = 2 in EA parameters
- Asian session: 02:00-11:00 platform time
- European session: 11:00-19:00 platform time
- American session: 19:00-02:00 platform time
```

---

## ⚡ Performance Issues

### Issue: High CPU Usage

**Symptoms:**
- MT5 becomes sluggish
- Other EAs slow down
- Computer fans running hard

**Causes:**
1. Too many symbols monitored simultaneously
2. Excessive calculation frequency
3. Large historical data buffers
4. Inefficient VPS resources

**Solutions:**
```
1. Reduce DashboardUpdateInterval (default: 5000ms)
2. Limit MaxTickHistory (default: 10000)
3. Disable unnecessary features
4. Run on dedicated VPS
5. Monitor fewer symbols concurrently
```

**Optimized Settings for Low Resources:**
```mql5
DashboardUpdateInterval = 10000    // 10 seconds
MaxTickHistory = 5000              // Reduced buffer
TestContinuousMode = false         // Passive only
ExportCSV = false                  // Disable exports
```

---

### Issue: Memory Leaks

**Symptoms:**
- MT5 memory usage grows over time
- Eventually crashes or freezes
- Restart temporarily fixes issue

**Solutions:**
```
1. Update to latest MT5 build
2. Reduce array sizes in parameters
3. Enable automatic cleanup
4. Restart MT5 daily as preventive measure
5. Report to developers if persists
```

**Memory Management Settings:**
```mql5
MaxSlippageSamples = 500      // Instead of 1000
MaxLatencySamples = 500       // Instead of 1000
AutoCleanupEnabled = true     // Enable garbage collection
```

---

## 🎯 Strategy-Specific Issues

### Issue: Conflicts with Existing EA

**Symptoms:**
- Both EAs behave erratically
- Orders duplicated or missing
- Risk calculations incorrect

**Solutions:**
```
1. Use different MagicNumbers for each EA
2. Run on separate charts/symbols
3. Ensure CustosAequitas in monitoring mode only
4. Disable TestContinuousMode when coexisting
5. Verify no order type conflicts
```

**Coexistence Configuration:**
```mql5
// CustosAequitas settings:
MagicTestOrders = 20260801    // Unique identifier
TestContinuousMode = false    // Passive monitoring only
TestLots = 0.01               // Minimal interference
EnableAdaptiveSizing = false  // Don't modify other EA
```

---

### Issue: Scalping Strategy Interference

**Symptoms:**
- Test orders affect scalping entries
- Spread widening during critical moments
- Latency measurements skew results

**Solutions:**
```
1. Schedule test batches during low-activity periods
2. Reduce TestBatchSize to minimum (5)
3. Use separate symbol for testing
4. Disable active probing entirely
5. Rely on passive observation only
```

**Scalping-Friendly Settings:**
```mql5
TestBatchSize = 5
TestIntervalMinutes = 240      // Every 4 hours
TestContinuousMode = false
PassiveMonitoringOnly = true
```

---

## 📞 Getting Human Help

### Before Contacting Support

**Gather This Information:**
```
1. MT5 build number (Help → About)
2. Broker name and account type
3. Symbol(s) being monitored
4. Duration of issue
5. Screenshots of problem
6. Relevant Journal excerpts
7. Steps already attempted
8. Expected vs actual behavior
```

### Journal Log Extraction

**How to Export Logs:**
```
1. Toolbox window → Journal tab
2. Right-click → Select All
3. Right-click → Copy
4. Paste into text file
5. Send to support with description
```

### Effective Bug Report Template

```
**Issue Title:** [Brief description]

**Environment:**
- MT5 Build: [number]
- OS: [Windows version]
- Broker: [name]
- Symbol: [pair]

**Problem Description:**
[What's happening?]

**Expected Behavior:**
[What should happen?]

**Steps to Reproduce:**
1. [First step]
2. [Second step]
3. [etc.]

**Screenshots/Logs:**
[Attach files]

**Troubleshooting Attempted:**
- [Action 1]
- [Action 2]
- [Result of each]
```

---

## 🔄 Recovery Procedures

### Full System Reset

**When to Use:**
- Multiple unresolved issues
- Corrupted configuration
- After major update

**Reset Steps:**
```
1. Export current settings (save as preset)
2. Remove EA from all charts
3. Close MT5 completely
4. Navigate to MQL5/Files/CustosAequitas/
5. Backup Data/ and Reports/ folders
6. Delete Configs/ folder contents
7. Restart MT5
8. Reattach EA with default settings
9. Restore backed up data files
10. Reconfigure parameters
```

### Data Recovery

**If CSV Files Corrupted:**
```
1. Stop EA immediately
2. Copy corrupted files to backup location
3. Delete corrupted files from Data folder
4. Restart EA (will create fresh files)
5. Attempt to merge old data manually if needed
```

**If HTML Reports Missing:**
```
1. Check Reports folder for partial files
2. Regenerate reports from CSV data
3. Use ReportGenerator.mqh standalone
4. Contact support for recovery tools
```

---

## 🛡️ Preventive Maintenance

### Daily Checks
- [ ] Verify EA running (blue icon on chart)
- [ ] Check Journal for errors
- [ ] Confirm dashboard updating
- [ ] Monitor disk space

### Weekly Tasks
- [ ] Review detection logs
- [ ] Export CSV data for backup
- [ ] Check for software updates
- [ ] Validate broker grade trends

### Monthly Actions
- [ ] Generate comprehensive report
- [ ] Archive old data files
- [ ] Recalibrate thresholds if needed
- [ ] Review and update configurations

---

## 📚 Additional Resources

### Documentation Files
- `README.md` - Overview and quick start
- `INSTALLATION.md` - Setup instructions
- `INTERPRETATION.md` - Results analysis guide
- This file (`TROUBLESHOOTING.md`) - Problem resolution

### External Resources
- MQL5 Documentation: https://www.mql5.com/en/docs
- MQL5 Forum: https://www.mql5.com/en/forum
- BrokerCompare: For alternative broker research
- ForexPeaceArmy: For broker reviews and complaints

---

**Still Having Issues?**

1. Review this guide thoroughly
2. Search GitHub Issues for similar problems
3. Ask in Discord community channel
4. Submit detailed bug report
5. Consider professional consultation for critical issues

---

*Last Updated: August 2026*  
*Version: 1.0.0*

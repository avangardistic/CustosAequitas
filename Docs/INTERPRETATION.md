# 📊 CustosAequitas - Results Interpretation Guide

## *"Transforming data into actionable intelligence"*

---

## 🎯 Understanding Your Broker Grade

### The Grading Philosophy

CustosAequitas uses a **weighted scoring system** that evaluates multiple dimensions of broker behavior. The final grade (A-F) represents the **probability of honest execution** based on statistical evidence.

### Grade Breakdown

#### 🟢 Grade A (90-100): Direct Market Access
**Characteristics:**
- Slippage ratio: ≤ 1.2 (nearly random distribution)
- Latency: < 50ms average, minimal spikes
- Requote rate: < 10%
- Spread consistency: Stable, matches industry averages
- Fractal dimension: 0.6-0.8 (natural market behavior)
- Entropy: > 0.8 (high randomness)

**What This Means:**
Your broker likely operates an **A-Book model**, passing orders directly to liquidity providers. Execution is fair and unbiased.

**Recommended Actions:**
- ✅ Trade with standard risk parameters (2% per trade)
- ✅ Use market orders confidently
- ✅ Standard stop-loss distances acceptable
- ✅ No special hardening required

---

#### 🟡 Grade B (75-89): Filtered Execution
**Characteristics:**
- Slippage ratio: 1.2-1.5 (slight negative bias)
- Latency: 50-100ms average, occasional spikes
- Requote rate: 10-20%
- Spread: Occasionally widens during volatility
- Fractal dimension: 0.5-0.7
- Entropy: 0.6-0.8

**What This Means:**
Your broker uses a **hybrid model** - some orders go to LPs, others are internalized. Minor manipulation may occur but isn't systematic.

**Recommended Actions:**
- ⚠️ Reduce risk to 1.5% per trade
- ⚠️ Prefer limit orders over market orders
- ⚠️ Use FOK (Fill or Kill) order type
- ⚠️ Implement basic stop hardening (wider stops)

---

#### 🟠 Grade C (60-74): Suspicious Behavior
**Characteristics:**
- Slippage ratio: 1.5-1.8 (clear negative bias)
- Latency: 100-150ms, frequent spikes
- Requote rate: 20-35%
- Spread: Regularly widens before entries
- Fractal dimension: 0.4-0.6 (some smoothing)
- Entropy: 0.5-0.6 (pattern repetition)

**What This Means:**
Your broker exhibits **systematic manipulation patterns**. B-Book operations likely dominate. Profitable traders face resistance.

**Recommended Actions:**
- ⚠️ Reduce risk to 1.0% per trade
- ⚠️ Mandatory limit orders only
- ⚠️ Aggressive stop hardening (2.5x ATR)
- ⚠️ Move to breakeven quickly (10-15 pips)
- ⚠️ Avoid trading during news events
- ⚠️ Consider broker change long-term

---

#### 🔴 Grade D (40-59): Severe Manipulation
**Characteristics:**
- Slippage ratio: 1.8-2.5 (severe bias)
- Latency: 150-250ms, constant spikes
- Requote rate: 35-50%
- Spread: Highly manipulated, unpredictable
- Fractal dimension: < 0.4 (artificial smoothing)
- Entropy: < 0.5 (algorithmic generation)

**What This Means:**
Your broker operates a **predatory B-Book model**. Client losses are the primary revenue source. Trading is mathematically disadvantaged.

**Recommended Actions:**
- ❌ Stop live trading immediately
- ❌ Withdraw funds if possible
- ❌ Switch to regulated broker
- ⚠️ If must trade: 0.5% risk maximum
- ⚠️ Use mental stops only
- ⚠️ Scalping strategies only (quick in/out)

---

#### ⛔ Grade F (0-39): Highly Malicious
**Characteristics:**
- Slippage ratio: > 2.5 (extreme bias)
- Latency: > 250ms or highly asymmetric
- Requote rate: > 50%
- Spread: Weaponized against positions
- Fractal dimension: < 0.3 (clearly artificial)
- Entropy: < 0.3 (predictable patterns)

**What This Means:**
Your broker is **actively hostile** to client profitability. Every mechanism is designed to extract client capital.

**Recommended Actions:**
- 🚨 CEASE TRADING IMMEDIATELY
- 🚨 Document all evidence for regulatory complaint
- 🚨 Initiate fund withdrawal
- 🚨 Report to regulatory authority
- 🚨 Share findings with trading community

---

## 📈 Detailed Metric Interpretation

### 1. Slippage Analysis

#### Negative/Positive Ratio
```
Ratio = Count(Negative Slippage) / Count(Positive Slippage)
```

**Interpretation:**
| Ratio | Status | Meaning |
|-------|--------|---------|
| 0.8-1.2 | 🟢 Healthy | Random distribution (fair) |
| 1.2-1.5 | 🟡 Mild Bias | Slight negative tendency |
| 1.5-1.8 | 🟠 Concerning | Systematic bias present |
| 1.8-2.5 | 🔴 Severe | Clear manipulation |
| > 2.5 | ⛔ Critical | Extreme exploitation |

**Example:**
- 45 negative slippage events, 25 positive events
- Ratio = 45/25 = 1.8
- **Verdict**: Severe manipulation (🔴)

#### Magnitude Asymmetry
```
Avg Negative Slippage: -2.3 pips
Avg Positive Slippage: +0.4 pips
Asymmetry Factor: 5.75x
```

**Red Flag:** When average negative slippage exceeds average positive by > 3x, broker is systematically worsening fills on losing trades.

---

### 2. Latency Profiling

#### Round-Trip Latency
```
Baseline: 35-50ms   (VPS near broker)
Normal:   50-100ms  (Good connection)
Warning:  100-200ms (Investigate cause)
Danger:   > 200ms   (Manipulation likely)
```

**Critical Pattern:**
If latency spikes correlate with:
- Profitable trade entries → 🚨 Manipulation
- News events → ⚠️ Could be legitimate
- Random times → ✅ Normal network issues

#### BUY/SELL Asymmetry
```
BUY Average Latency:  42ms
SELL Average Latency:  38ms
Asymmetry: 10.5%
```

**Thresholds:**
- < 10% asymmetry: ✅ Normal
- 10-20% asymmetry: ⚠️ Investigate
- > 20% asymmetry: 🚨 Directional bias detected

---

### 3. Requote Analysis

#### Requote Frequency
```
Total Orders: 100
Requotes: 28
Requote Rate: 28%
```

**Interpretation:**
| Rate | Status | Action |
|------|--------|--------|
| < 10% | 🟢 Normal | No action |
| 10-20% | 🟡 Elevated | Use FOK orders |
| 20-35% | 🟠 High | Limit orders only |
| 35-50% | 🔴 Severe | Reduce trading |
| > 50% | ⛔ Critical | Stop trading |

#### Requote Outcome Analysis
```
Requotes Leading to Better Price: 3 (12%)
Requotes Leading to Worse Price: 22 (88%)
```

**Red Flag:** If > 70% of requotes result in worse prices, broker is using requotes as a manipulation tool.

---

### 4. Spread Forensics

#### Spread Behavior Patterns
```
Average Spread: 0.8 pips
Median Spread:  0.7 pips
Max Spread:     3.2 pips
Std Deviation:  0.4 pips
```

**Manipulation Indicators:**

**Pattern A: Entry Poisoning**
- Spread normal before EA signal
- Spread widens 2-3x at entry trigger
- Spread normalizes after entry filled
- **Verdict**: Targeted spread manipulation

**Pattern B: Exit Tax**
- Spread stable during position holding
- Spread spikes when closing profitable position
- **Verdict**: Profit extraction mechanism

**Pattern C: Session Manipulation**
- Spread abnormally wide during specific sessions
- Correlates with your active trading hours
- **Verdict**: Time-targeted manipulation

---

### 5. Fractal Complexity Analysis

#### Higuchi Fractal Dimension (H)
```
H Value Range: 0.0 - 1.0

H ≈ 0.5: Random walk (organic market)
H ≈ 1.0: White noise (smooth, artificial)
H ≈ 0.0: Constant value (impossible in real markets)
```

**Interpretation:**
| H Value | Market Type | Manipulation % |
|---------|-------------|----------------|
| 0.6-0.8 | Organic     | 0-15%          |
| 0.5-0.6 | Mixed       | 15-30%         |
| 0.4-0.5 | Smoothed    | 30-50%         |
| 0.3-0.4 | Artificial  | 50-70%         |
| < 0.3   | Generated   | > 70%          |

**Calculation Example:**
```
Observed H: 0.42
Benchmark H (real market): 0.65
Manipulation Index = 100 * (1 - 0.42/0.65) = 35.4%
```

---

### 6. Permutation Entropy

#### Entropy Values
```
PE Range: 0.0 - 1.0

High Entropy (0.8-1.0): Unpredictable, natural
Medium Entropy (0.5-0.8): Some patterns
Low Entropy (0.0-0.5): Repetitive, algorithmic
```

**Interpretation:**
- **> 0.8**: A-Book broker (client orders hedged)
- **0.5-0.8**: Hybrid model (partial internalization)
- **< 0.5**: B-Book broker (orders internalized)

**Why It Matters:**
Low entropy indicates price patterns are being **generated** rather than **discovered** through market forces.

---

### 7. Stop-Loss Hunting Detection

#### Hit Ratio Analysis
```
Expected Random Hits: 15% of trades
Actual Stop Hits: 28% of trades
Excess Hit Ratio: (28-15)/15 = 86.7%
```

**Thresholds:**
| Excess Ratio | Status | Confidence |
|--------------|--------|------------|
| < 20% | 🟢 Normal | Random variance |
| 20-50% | 🟡 Suspicious | Likely targeting |
| 50-100% | 🟠 Confirmed | Statistical certainty |
| > 100% | 🔴 Severe | Obvious manipulation |

**Pattern Recognition:**
- Stops hit within 1-2 pips, then reversal → 🚨 Hunting
- Multiple accounts report same levels hit → 🚨 Coordinated
- Stops hit before major news, then correct direction → 🚨 Premature

---

## 🧪 Statistical Confidence Levels

### Understanding Sample Size Requirements

```
Minimum Samples for Preliminary Analysis: 30
Minimum Samples for Reliable Analysis: 50
Samples for High Confidence: 100+
Samples for Legal Evidence: 500+
```

### Confidence Intervals

CustosAequitas calculates **95% confidence intervals** for all metrics:

```
Slippage Ratio: 1.8 [1.6 - 2.1] @ 95% CI
```

This means: "We are 95% confident the true ratio lies between 1.6 and 2.1"

**Narrow CI** = High precision (reliable)  
**Wide CI** = Low precision (need more data)

### P-Value Interpretation

When comparing metrics to expected values:

| P-Value | Significance | Interpretation |
|---------|--------------|----------------|
| < 0.01 | Highly Significant | < 1% chance of random occurrence |
| 0.01-0.05 | Significant | < 5% chance of random occurrence |
| 0.05-0.10 | Marginally Significant | Weak evidence |
| > 0.10 | Not Significant | Could be random |

---

## 📊 Dashboard Reading Guide

### Live Dashboard Layout

```
═══════════════════════════════════════════════════
        CUSTOS AEQUITAS - LIVE MONITOR
═══════════════════════════════════════════════════
🚦 Broker Grade:  C- (Suspicious)      Score: 67/100
📊 Manipulation %:  34.2%              Status: ⚠️ CAUTION
⚡ Server Status:    Variable          Latency: 127ms
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SLIPPAGE:   +0.3 / -1.9 (ratio: 1.9)   Risk: 🔴
REQUOTES:   18 of 62 (29.0%)           Risk: 🟠
SPREAD:     1.1 avg (0.6-2.8)         Risk: 🟡
LATENCY:    127ms (baseline: 45ms)    Risk: 🔴

[Detection Log]
[15:42:18] 🔴 Slippage spike: -4.2 pips on BUY
[15:38:55] ⚠️ Requote cluster: 3 in last 5 trades
[15:35:12] ✅ Spread normalized after widening
[15:31:08] 🔴 Latency anomaly: 234ms during profit
```

### Color Coding System

| Color | Meaning | Action Required |
|-------|---------|-----------------|
| 🟢 Green | Safe | Continue normal operations |
| 🟡 Yellow | Warning | Monitor closely, consider adjustments |
| 🟠 Orange | High Risk | Implement hardening strategies |
| 🔴 Red | Danger | Immediate action required |

### Alert Prioritization

**Priority 1 (Critical):**
- Broker grade drops to D or F
- Circuit breaker triggered
- Multiple severe manipulation signals

**Priority 2 (High):**
- Single severe manipulation indicator
- Broker grade drops one level
- Unusual pattern detected

**Priority 3 (Medium):**
- Warning thresholds exceeded
- Minor anomalies detected
- Parameter adjustments recommended

---

## 🎯 Action Matrix by Scenario

### Scenario 1: Excellent Broker (Grade A)
**Metrics:** All green, manipulation < 10%

**Actions:**
- ✅ Maintain standard risk (2%)
- ✅ Use preferred order types
- ✅ Standard stop distances
- ✅ No special filters needed
- 📊 Continue monitoring monthly

---

### Scenario 2: Minor Issues (Grade B)
**Metrics:** Some yellow, manipulation 10-20%

**Actions:**
- ⚠️ Reduce risk to 1.5%
- ⚠️ Prefer limit orders
- ⚠️ Use FOK fill type
- ⚠️ Widen stops by 20%
- 📊 Weekly monitoring

---

### Scenario 3: Concerning Patterns (Grade C)
**Metrics:** Multiple orange, manipulation 20-35%

**Actions:**
- ⚠️ Reduce risk to 1.0%
- ⚠️ Limit orders mandatory
- ⚠️ Aggressive breakeven (10 pips)
- ⚠️ Avoid news trading
- ⚠️ Scale in/out positions
- 📊 Daily monitoring
- 🔄 Plan broker transition

---

### Scenario 4: Dangerous Broker (Grade D)
**Metrics:** Multiple red, manipulation 35-50%

**Actions:**
- 🚨 Halt live trading
- 🚨 Withdraw majority of funds
- 🚨 Research alternative brokers
- ⚠️ If must trade: 0.5% risk max
- ⚠️ Mental stops only
- ⚠️ Sub-minute timeframes only
- 📊 Continuous monitoring

---

### Scenario 5: Predatory Broker (Grade F)
**Metrics:** All red, manipulation > 50%

**Actions:**
- 🚨 IMMEDIATELY STOP TRADING
- 🚨 Document all evidence
- 🚨 File regulatory complaint
- 🚨 Initiate full withdrawal
- 🚨 Warn trading community
- 🚨 Never return to this broker

---

## 📈 Trend Analysis

### Improving Trends
```
Week 1: Grade D (52)
Week 2: Grade C (61)
Week 3: Grade C (68)
Week 4: Grade B (74)
```
**Interpretation:** Broker improving practices. Possibly changed systems or LPs. Cautious optimism warranted.

### Degenerating Trends
```
Week 1: Grade B (78)
Week 2: Grade C (69)
Week 3: Grade C (63)
Week 4: Grade D (54)
```
**Interpretation:** Broker deteriorating. New management? Financial stress? Prepare exit strategy.

### Volatile Patterns
```
Week 1: Grade B (76)
Week 2: Grade D (51)
Week 3: Grade B (79)
Week 4: Grade C (65)
```
**Interpretation:** Inconsistent execution. Possible LP rotation or intentional variability. High uncertainty.

---

## 🧾 Report Section Guide

### Executive Summary
- **Purpose**: Quick assessment (30-second read)
- **Focus**: Grade, score, recommendation
- **Action**: Decide whether to continue reading

### Slippage Analysis Section
- **Purpose**: Execution quality assessment
- **Key Metrics**: Ratio, magnitude, autocorrelation
- **Red Flags**: Ratio > 1.8, magnitude asymmetry > 3x

### Latency Analysis Section
- **Purpose**: Speed and fairness evaluation
- **Key Metrics**: Average, max, BUY/SELL asymmetry
- **Red Flags**: > 200ms, > 20% asymmetry

### Requote Analysis Section
- **Purpose**: Order rejection patterns
- **Key Metrics**: Frequency, outcome distribution
- **Red Flags**: > 30% rate, > 70% worse outcomes

### Spread Analysis Section
- **Purpose**: Cost variability assessment
- **Key Metrics**: Average, max, volatility
- **Red Flags**: Spikes before entries, session bias

### Forensic Analysis Section
- **Purpose**: Market authenticity verification
- **Key Metrics**: Fractal dimension, entropy
- **Red Flags**: H < 0.5, PE < 0.6

### Recommendations Section
- **Purpose**: Actionable guidance
- **Structure**: Priority-ordered list
- **Focus**: Specific, implementable changes

---

## 📞 When to Seek External Help

### Contact Regulator If:
- Grade F confirmed with 500+ samples
- Funds withheld during withdrawal
- Clear evidence of price manipulation
- Multiple victims identified

### Contact Lawyer If:
- Significant financial losses (> $10,000)
- Broker unresponsive to complaints
- Regulatory complaint unresolved
- Class action possibility exists

### Contact Community If:
- Confirming patterns reported by others
- Sharing evidence for collective action
- Warning fellow traders
- Seeking broker alternatives

---

## 🎓 Advanced Interpretation Techniques

### Cross-Validation Methods

**Method 1: Multi-Symbol Comparison**
Test same broker across different symbols:
- EURUSD: Grade B
- GBPJPY: Grade D
- **Insight**: Broker manipulates exotic pairs more

**Method 2: Time-of-Day Analysis**
Segment data by session:
- Asian: Grade A
- European: Grade B
- American: Grade C
- **Insight**: Liquidity affects execution quality

**Method 3: Position Size Correlation**
Compare small vs large orders:
- 0.01 lots: Grade B
- 1.00 lots: Grade D
- **Insight**: Broker penalizes larger positions

### Statistical Tests

**Chi-Square Test for Slippage Distribution:**
Tests if slippage distribution differs from random expectation.
- P < 0.05: Non-random (suspicious)
- P < 0.01: Highly non-random (manipulation likely)

**T-Test for Latency Comparison:**
Compares BUY vs SELL latency means.
- P < 0.05: Significant difference (bias present)
- Effect size > 0.5: Practically significant

---

## 📚 Glossary of Terms

| Term | Definition |
|------|------------|
| **A-Book** | Broker passes orders to liquidity providers |
| **B-Book** | Broker internalizes client orders |
| **Slippage** | Difference between requested and executed price |
| **Requote** | Broker offers new price instead of requested |
| **Latency** | Time delay between order request and execution |
| **Fractal Dimension** | Measure of price series complexity |
| **Entropy** | Measure of randomness/unpredictability |
| **Stop Hunting** | Artificial price moves to trigger stops |
| **FOK** | Fill or Kill - entire order filled or rejected |
| **IOC** | Immediate or Cancel - partial fills allowed |

---

**Remember**: No single metric proves manipulation. Look for **converging evidence** across multiple indicators. Statistical patterns suggest probability, not certainty.

---

*Last Updated: August 2026*  
*Version: 1.0.0*

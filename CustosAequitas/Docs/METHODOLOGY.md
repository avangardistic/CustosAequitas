# CustosAequitas Forensic Methodology v1.0.0

## Overview

This document describes the statistical methodology used by CustosAequitas for broker execution analysis. This methodology is designed to produce **measurable, reproducible, statistically defensible evidence** about execution behavior while explicitly communicating uncertainty.

---

## Core Principles

### 1. Observation ≠ Causation

The system distinguishes between:
- **Observation**: Raw data point (e.g., "slippage was -2 pips")
- **Statistical Anomaly**: Deviation from expected distribution (p < 0.05)
- **Significant Pattern**: Persistent anomaly over time
- **Evidence**: Multiple aligned indicators with confidence measures
- **Conclusion**: Actionable recommendation with uncertainty bounds

### 2. Evidence Hierarchy

```
Level 0: Insufficient Data (< 30 samples)
Level 1: Preliminary Observation (30-49 samples)
Level 2: Statistical Anomaly (50-99 samples, p < 0.05)
Level 3: Significant Pattern (100+ samples, effect size > threshold)
Level 4: Strong Evidence (multiple indicators, directional consistency)
Level 5: Very Strong Evidence (persistent over time, alternative explanations ruled out)
```

### 3. Confidence Adjustment

All scores are adjusted by sample size:

```
Adjusted_Score = Raw_Score × Confidence_Factor

Where:
Confidence_Factor = min(1.0, n / n_required)
n_required = 100 for high confidence
```

---

## Statistical Methods

### Slippage Analysis

#### Bias Ratio Calculation

```
Bias_Ratio = Count(Negative_Slippage) / Count(Positive_Slippage)

Interpretation:
- 0.8 - 1.2: Normal (symmetric)
- 1.2 - 1.5: Mild negative bias
- 1.5 - 1.8: Moderate negative bias (WARNING)
- > 1.8: Severe negative bias (DANGER)
```

#### Magnitude Ratio

```
Magnitude_Ratio = Avg|Negative_Slippage| / Avg|Positive_Slippage|

This captures whether negative slippage is not only more frequent but also larger in magnitude.
```

#### Directional Asymmetry Test

```
Buy_Bias = Neg_Buy_Count / Pos_Buy_Count
Sell_Bias = Neg_Sell_Count / Pos_Sell_Count
Asymmetry_Detected = |Buy_Bias - Sell_Bias| > 0.5

This tests whether one direction (BUY or SELL) receives systematically worse execution.
```

### Latency Analysis

#### Percentile Measurements

```
P50 (Median): Typical latency
P95: High latency threshold
P99: Extreme latency events
```

#### BUY/SELL Asymmetry

```
Latency_Asymmetry = |Avg_Latency_BUY - Avg_Latency_SELL| / Overall_Avg

Threshold: > 20% indicates potential directional discrimination
```

### Spread Analysis

#### Spike Detection

```
Spike_Threshold = Median_Spread × Multiplier (default: 2.5)
Spike_Rate = Count(Spread > Spike_Threshold) / Total_Observations

High spike rate during trade entries suggests potential front-running.
```

### Requote/Rejection Analysis

#### Rejection Rate

```
Rejection_Rate = Count(Rejected_Requests) / Total_Requests

Thresholds:
- < 10%: Normal
- 10-20%: Warning
- > 20%: Danger
```

---

## Broker Scoring System

### Score Components

```
Total_Score = Slippage_Score × 0.40 + Latency_Score × 0.40 + Pattern_Score × 0.20
```

#### Slippage Score (0-100)

```
Slippage_Score = 100 / (1 + Bias_Ratio)

Example:
- Bias_Ratio = 1.0 → Score = 50
- Bias_Ratio = 0.5 → Score = 67
- Bias_Ratio = 2.0 → Score = 33
```

#### Latency Score (0-100)

```
Latency_Score = max(0, 100 - Avg_Latency_ms / 2)

Example:
- 20ms → Score = 90
- 100ms → Score = 50
- 200ms → Score = 0
```

#### Pattern Score (0-100)

Based on:
- Fractal dimension (Higuchi method)
- Permutation entropy
- Temporal clustering of adverse events

### Grade Boundaries

| Grade | Score Range | Interpretation |
|-------|-------------|----------------|
| A | 90-100 | Excellent - Direct Market Access quality |
| B | 75-89 | Good - Minor execution issues |
| C | 60-74 | Fair - Moderate concerns, monitor closely |
| D | 40-59 | Poor - Significant problems detected |
| F | 0-39 | Fail - Critical execution degradation |

---

## Statistical Tests

### Sample Size Requirements

| Analysis Type | Minimum | Reliable | High Confidence |
|---------------|---------|----------|-----------------|
| Slippage | 30 | 50 | 100 |
| Latency | 30 | 50 | 100 |
| Spread | 50 | 100 | 200 |
| Requotes | 20 | 50 | 100 |

### Power Analysis

For detecting a medium effect size (Cohen's d = 0.5) with α = 0.05 and power = 0.80:
- Required sample size: ~64 observations per group

### Multiple Comparison Correction

When testing multiple hypotheses simultaneously, Bonferroni correction is applied:

```
Adjusted_α = α / k

Where k = number of simultaneous tests
```

---

## False Positive Controls

### Known False Positive Sources

1. **News Events**: Legitimate spread widening during high volatility
2. **Session Rollover**: Low liquidity at market close/open
3. **Symbol Characteristics**: Some pairs naturally have wider spreads
4. **Network Issues**: Client-side connectivity problems
5. **Platform Delays**: MT5 terminal processing time

### Mitigation Strategies

1. **Time Filtering**: Exclude known news events (use economic calendar)
2. **Session Awareness**: Analyze by trading session
3. **Symbol Normalization**: Compare to symbol-specific benchmarks
4. **Multi-Indicator Confirmation**: Require multiple anomalies before flagging
5. **Temporal Persistence**: Require patterns to persist over time

---

## Limitations

### Technical Constraints

1. **Server-Side Opacity**: Cannot observe broker internal systems
2. **Timing Resolution**: Limited to millisecond precision
3. **Historical Data**: Strategy tester cannot replicate live execution perfectly
4. **Order Flow**: Cannot see other clients' orders

### Statistical Limitations

1. **Correlation ≠ Causation**: Anomalies may have innocent explanations
2. **Sample Bias**: Observed trades may not represent all execution scenarios
3. **Regime Dependence**: Results vary by market conditions
4. **Multiple Testing**: Increased false positive risk with many indicators

---

## Reproducibility

### Report Metadata

Every forensic report includes:
- CustosAequitas version
- Methodology version
- Configuration parameters
- Symbol and timeframe
- Account type (demo/live)
- Observation period
- Sample sizes
- Confidence levels

### Data Export

CSV exports enable independent verification using:
- R
- Python (pandas, scipy, statsmodels)
- MATLAB
- Excel

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025 | Initial methodology documentation |

---

## References

### Academic

1. Cohen, J. (1988). *Statistical Power Analysis for the Behavioral Sciences*
2. Efron, B., & Tibshirani, R.J. (1993). *An Introduction to the Bootstrap*
3. Hasbrouck, J. (2007). *Empirical Market Microstructure*
4. O'Hara, M. (1995). *Market Microstructure Theory*

### Industry Standards

1. SEC Rule 605/606 (Execution Quality Reporting)
2. MiFID II Best Execution Requirements
3. IOSCO Principles for Dark Pools

---

*Methodology reviewed against current academic literature in market microstructure and statistical analysis. Updated periodically as research evolves.*

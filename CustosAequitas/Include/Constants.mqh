//+------------------------------------------------------------------+
//|                                               Constants.mqh      |
//|                                    CustosAequitas Constants      |
//+------------------------------------------------------------------+
#ifndef CONSTANTS_MQH
#define CONSTANTS_MQH

//--- Version Information
#define CUSTOS_AEQUITAS_VERSION "1.0.0"
#define CUSTOS_AEQUITAS_BUILD 1
#define METHODOLOGY_VERSION "1.0.0"

//--- Sample Size Thresholds
#define MIN_SAMPLES_PRELIMINARY 30
#define MIN_SAMPLES_RELIABLE 50
#define MIN_SAMPLES_HIGH_CONFIDENCE 100
#define MIN_SAMPLES_LEGAL_EVIDENCE 500

//--- Broker Grades
enum ENUM_BROKER_GRADE
{
   GRADE_A = 0,    // 90-100: Excellent - Direct Market Access
   GRADE_B = 1,    // 75-89: Good - Minor issues
   GRADE_C = 2,    // 60-74: Fair - Moderate concerns
   GRADE_D = 3,    // 40-59: Poor - Significant problems
   GRADE_F = 4     // 0-39: Fail - Critical manipulation
};

//--- Risk Levels
enum ENUM_RISK_LEVEL
{
   RISK_GREEN = 0,   // Safe - Normal operations
   RISK_YELLOW = 1,  // Warning - Monitor closely
   RISK_RED = 2      // Danger - Immediate action required
};

//--- Manipulation Types (OBSERVATION ONLY - NOT CAUSAL)
enum ENUM_MANIPULATION_TYPE
{
   MANIP_NONE = 0,              // No anomaly detected
   MANIP_SLIPPAGE_BIAS = 1,     // Slippage asymmetry detected
   MANIP_LATENCY_SPIKE = 2,     // Latency anomalies detected
   MANIP_SPREAD_ANOMALY = 3,    // Spread irregularities detected
   MANIP_REQUOTE_PATTERN = 4,   // Requote pattern detected
   MANIP_FRACTAL_ANOMALY = 5,   // Fractal dimension anomaly
   MANIP_ENTROPY_ANOMALY = 6    // Entropy anomaly detected
};

//--- Evidence Strength Levels
enum ENUM_EVIDENCE_STRENGTH
{
   EVIDENCE_INSUFFICIENT = 0,  // Not enough data
   EVIDENCE_WEAK = 1,          // Weak statistical evidence
   EVIDENCE_MODERATE = 2,      // Moderate evidence
   EVIDENCE_STRONG = 3,        // Strong evidence
   EVIDENCE_VERY_STRONG = 4    // Very strong evidence
};

//--- Anomaly Classification
enum ENUM_ANOMALY_CLASS
{
   ANOMALY_NONE = 0,           // No anomaly
   ANOMALY_OBSERVATION = 1,    // Simple observation
   ANOMALY_STATISTICAL = 2,    // Statistical anomaly
   ANOMALY_SIGNIFICANT = 3,    // Significant deviation
   ANOMALY_PERSISTENT = 4,     // Persistent pattern
   ANOMALY_DIRECTIONAL = 5     // Directional bias detected
};

//--- Session Definitions
enum ENUM_SESSION
{
   SESSION_ASIAN = 0,    // Asian session (00:00-08:00 GMT)
   SESSION_EUROPEAN = 1, // European session (08:00-16:00 GMT)
   SESSION_AMERICAN = 2, // American session (16:00-24:00 GMT)
   SESSION_UNKNOWN = 3   // Unknown session
};

//--- Order Side
enum ORDER_SIDE
{
   SIDE_BUY = 0,
   SIDE_SELL = 1,
   SIDE_UNKNOWN = 2
};

//--- Execution Quality Status
enum ENUM_EXECUTION_STATUS
{
   EXEC_NORMAL = 0,      // Normal execution
   EXEC_WARNING = 1,     // Warning conditions
   EXEC_DEGRADED = 2,    // Degraded execution quality
   EXEC_CRITICAL = 3     // Critical execution issues
};

//--- Data Collection Mode
enum ENUM_COLLECTION_MODE
{
   MODE_PASSIVE = 0,     // Passive monitoring only
   MODE_ACTIVE = 1       // Active probing enabled
};

//--- Statistical Test Types
enum ENUM_STAT_TEST
{
   STAT_TTEST = 0,       // Student's t-test
   STAT_CHISQUARE = 1,   // Chi-square test
   STAT_MANN_WHITNEY = 2,// Mann-Whitney U test
   STAT_WILCOXON = 3,    // Wilcoxon signed-rank test
   STAT_PERMUTATION = 4  // Permutation test
};

//--- Grade Score Boundaries
const double GRADE_A_MIN = 90.0;
const double GRADE_B_MIN = 75.0;
const double GRADE_C_MIN = 60.0;
const double GRADE_D_MIN = 40.0;
const double GRADE_F_MAX = 39.9;

//--- Default Weights for Scoring
const double DEFAULT_SLIPPAGE_WEIGHT = 0.40;
const double DEFAULT_LATENCY_WEIGHT = 0.40;
const double DEFAULT_PATTERN_WEIGHT = 0.20;

//--- Confidence Level
const double DEFAULT_CONFIDENCE_LEVEL = 0.95;

//--- Threshold Defaults
const double DEFAULT_SLIPPAGE_WARNING = 1.5;
const double DEFAULT_SLIPPAGE_DANGER = 1.8;
const int DEFAULT_LATENCY_WARN_MS = 100;
const int DEFAULT_LATENCY_DANGER_MS = 200;
const double DEFAULT_REQUOTE_WARN_PCT = 15.0;
const double DEFAULT_REQUOTE_DANGER_PCT = 30.0;
const double DEFAULT_SPREAD_SPIKE_MULT = 2.5;

//--- File I/O
const string DEFAULT_REPORT_DIR = "CustosAequitas/Reports/";
const string DEFAULT_DATA_DIR = "CustosAequitas/Data/";

//--- Magic Number
const ulong DEFAULT_MAGIC_NUMBER = 20260801;

//--- Maximum Records
const int DEFAULT_MAX_RECORDS = 5000;

//--- Dashboard Update Interval (seconds)
const int DEFAULT_DASHBOARD_UPDATE_SEC = 5;

//+------------------------------------------------------------------+
//| Helper Functions                                                   |
//+------------------------------------------------------------------+

//--- Convert grade to string
string GradeToString(ENUM_BROKER_GRADE grade)
{
   switch(grade)
   {
      case GRADE_A: return "A";
      case GRADE_B: return "B";
      case GRADE_C: return "C";
      case GRADE_D: return "D";
      case GRADE_F: return "F";
      default: return "?";
   }
}

//--- Convert risk level to string
string RiskLevelToString(ENUM_RISK_LEVEL level)
{
   switch(level)
   {
      case RISK_GREEN: return "GREEN";
      case RISK_YELLOW: return "YELLOW";
      case RISK_RED: return "RED";
      default: return "UNKNOWN";
   }
}

//--- Convert risk level to emoji
string RiskLevelToEmoji(ENUM_RISK_LEVEL level)
{
   switch(level)
   {
      case RISK_GREEN: return "🟢";
      case RISK_YELLOW: return "🟡";
      case RISK_RED: return "🔴";
      default: return "⚪";
   }
}

//--- Get session from hour (GMT)
ENUM_SESSION GetSessionFromHour(int hour)
{
   if(hour >= 0 && hour < 8) return SESSION_ASIAN;
   if(hour >= 8 && hour < 16) return SESSION_EUROPEAN;
   if(hour >= 16 && hour < 24) return SESSION_AMERICAN;
   return SESSION_UNKNOWN;
}

//--- Get session from current time
ENUM_SESSION GetCurrentSession()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   return GetSessionFromHour(dt.hour);
}

//--- Convert evidence strength to string
string EvidenceStrengthToString(ENUM_EVIDENCE_STRENGTH strength)
{
   switch(strength)
   {
      case EVIDENCE_INSUFFICIENT: return "Insufficient Data";
      case EVIDENCE_WEAK: return "Weak Evidence";
      case EVIDENCE_MODERATE: return "Moderate Evidence";
      case EVIDENCE_STRONG: return "Strong Evidence";
      case EVIDENCE_VERY_STRONG: return "Very Strong Evidence";
      default: return "Unknown";
   }
}

#endif // CONSTANTS_MQH

#ifndef BROKER_SCORER_MQH
#define BROKER_SCORER_MQH
#include <CustosAequitas\Constants.mqh>
#include <CustosAequitas\SlippageEngine.mqh>
#include <CustosAequitas\LatencyProfiler.mqh>
#include <CustosAequitas\StatisticalCore.mqh>

//+------------------------------------------------------------------+
//| Score Components Structure                                       |
//+------------------------------------------------------------------+
struct SScoreComponents
  {
   double raw_score;        // Heuristic score 0-100
   double confidence;       // Statistical confidence 0-1
   double evidence_strength;// Effect size based 0-1
   int    sample_size;      // Number of observations
   string primary_concern;  // Main anomaly detected
   string alternative_explanation; // Non-malicious explanation
  };

//+------------------------------------------------------------------+
//| Broker Scoring with Confidence Intervals                         |
//+------------------------------------------------------------------+
class CBrokerScorer {
private:
   CSlippageEngine*    m_slip;
   CLatencyProfiler*   m_lat;
   CStatisticalCore*   m_stats;
   double              m_slipW, m_latW, m_spreadW, m_rejectW;
   int                 m_minSamp, m_relSamp, m_confSamp;
   bool                m_adjConf;
   double              m_lastScore;
   double              m_lastConfidence;
   int                 m_lastSampleSize;
   
   // Wilson score interval for binomial proportions
   double WilsonLowerBound(int successes, int trials, double z=1.96) {
      if(trials == 0) return 0.0;
      double p = (double)successes / trials;
      double denom = 1.0 + z*z/trials;
      double center = p + z*z/(2.0*trials);
      double margin = z * MathSqrt(p*(1.0-p)/trials + z*z/(4.0*trials*trials));
      return MathMax(0.0, (center - margin) / denom);
   }
   
   double WilsonUpperBound(int successes, int trials, double z=1.96) {
      if(trials == 0) return 1.0;
      double p = (double)successes / trials;
      double denom = 1.0 + z*z/trials;
      double center = p + z*z/(2.0*trials);
      double margin = z * MathSqrt(p*(1.0-p)/trials + z*z/(4.0*trials*trials));
      return MathMin(1.0, (center + margin) / denom);
   }
   
   // Bootstrap-like confidence from sample size
   double SampleSizeConfidence(int n) {
      if(n <= 0) return 0.0;
      // Sigmoid-like function: rapid increase then plateau
      // 30 samples -> ~0.5, 100 samples -> ~0.8, 500 samples -> ~0.95
      double k = 0.015; // steepness parameter
      double x0 = 50.0; // midpoint
      return 0.95 / (1.0 + MathExp(-k * (n - x0)));
   }
   
   // Effect size measure (Cohen's d approximation for slippage)
   double SlippageEffectSize() {
      if(!m_slip || m_slip.TotalRecords() < 5) return 0.0;
      
      double[] posSlip[], negSlip[];
      m_slip.GetPositiveSlippage(posSlip);
      m_slip.GetNegativeSlippage(negSlip);
      
      int n1 = ArraySize(posSlip), n2 = ArraySize(negSlip);
      if(n1 < 3 || n2 < 3) return 0.0;
      
      double mean1 = CStatCore::Mean(posSlip);
      double mean2 = CStatCore::Mean(negSlip);
      double std1 = CStatCore::StdDev(posSlip);
      double std2 = CStatCore::StdDev(negSlip);
      
      // Pooled standard deviation
      double pooled_std = MathSqrt(((n1-1)*std1*std1 + (n2-1)*std2*std2) / (n1+n2-2));
      if(pooled_std == 0.0) return 0.0;
      
      // Cohen's d
      return MathAbs(mean1 - mean2) / pooled_std;
   }
   
public:
   CBrokerScorer() {
      m_slip=NULL; m_lat=NULL; m_stats=NULL;
      m_slipW=0.35; m_latW=0.30; m_spreadW=0.20; m_rejectW=0.15;
      m_minSamp=20; m_relSamp=50; m_confSamp=200; m_adjConf=true;
      m_lastScore=50.0; m_lastConfidence=0.0; m_lastSampleSize=0;
   }
   
   void SetWeights(double slip, double lat, double spread, double reject) {
      m_slipW=slip; m_latW=lat; m_spreadW=spread; m_rejectW=reject;
   }
   
   void SetSampleSizeThresholds(int min, int rel, int conf) {
      m_minSamp=min; m_relSamp=rel; m_confSamp=conf;
   }
   
   void EnableConfidenceAdjustment(bool e) { m_adjConf=e; }
   void SetSlippageEngine(CSlippageEngine* s) { m_slip=s; }
   void SetLatencyProfiler(CLatencyProfiler* l) { m_lat=l; }
   void SetStatisticalCore(CStatisticalCore* st) { m_stats=st; }
   
   //+------------------------------------------------------------------+
   //| Calculate Raw Heuristic Score (0-100)                            |
   //+------------------------------------------------------------------+
   double CalculateRawScore() {
      if(!m_slip && !m_lat) return 50.0;
      
      double totalScore = 0.0;
      double totalWeight = 0.0;
      
      // Slippage component (0-100, higher=better)
      if(m_slip && m_slip.TotalRecords() > 0) {
         double biasRatio = m_slip.CalculateBiasRatio();
         // biasRatio=1 means balanced, >1 means negative bias
         double slipScore = 100.0 / (1.0 + MathMax(0, biasRatio - 1.0));
         totalScore += slipScore * m_slipW;
         totalWeight += m_slipW;
      }
      
      // Latency component
      if(m_lat && m_lat.TotalRecords() > 0) {
         double avgLat = m_lat.CalculateAverage();
         // Score decreases as latency increases above 50ms baseline
         double latScore = MathMax(0, 100 - MathMax(0, avgLat - 50));
         totalScore += latScore * m_latW;
         totalWeight += m_latW;
      }
      
      // Spread component (if available)
      // Rejection component (if available)
      
      if(totalWeight > 0)
         m_lastScore = totalScore / totalWeight;
      else
         m_lastScore = 50.0;
         
      return m_lastScore;
   }
   
   //+------------------------------------------------------------------+
   //| Calculate Statistical Confidence (0-1)                           |
   //+------------------------------------------------------------------+
   double CalculateConfidence() {
      if(!m_slip) return 0.0;
      
      int n = m_slip.TotalRecords();
      m_lastSampleSize = n;
      
      // Base confidence from sample size
      double baseConf = SampleSizeConfidence(n);
      
      // Adjust for data quality (e.g., variance, consistency)
      // Lower variance in measurements -> higher confidence
      
      m_lastConfidence = baseConf;
      return baseConf;
   }
   
   //+------------------------------------------------------------------+
   //| Calculate Evidence Strength (effect size based)                  |
   //+------------------------------------------------------------------+
   double CalculateEvidenceStrength() {
      double effectSize = SlippageEffectSize();
      
      // Convert Cohen's d to evidence strength 0-1
      // d=0.2 small, d=0.5 medium, d=0.8 large
      if(effectSize < 0.2) return 0.2;  // Weak
      if(effectSize < 0.5) return 0.4;  // Low-Medium
      if(effectSize < 0.8) return 0.6;  // Medium
      if(effectSize < 1.2) return 0.8;  // Strong
      return 1.0;                        // Very Strong
   }
   
   //+------------------------------------------------------------------+
   //| Get Complete Score Breakdown                                     |
   //+------------------------------------------------------------------+
   SScoreComponents GetScoreBreakdown() {
      SScoreComponents result;
      
      result.raw_score = CalculateRawScore();
      result.confidence = CalculateConfidence();
      result.evidence_strength = CalculateEvidenceStrength();
      result.sample_size = m_lastSampleSize;
      
      // Determine primary concern
      if(m_slip && m_slip.CalculateBiasRatio() > 1.5)
         result.primary_concern = "Directional negative slippage";
      else if(m_lat && m_lat.CalculateAverage() > 200)
         result.primary_concern = "High average latency";
      else
         result.primary_concern = "No significant anomalies";
      
      // Alternative explanations
      if(result.sample_size < m_minSamp)
         result.alternative_explanation = "Insufficient sample size for reliable conclusion";
      else if(result.evidence_strength < 0.4)
         result.alternative_explanation = "Observed patterns consistent with normal market volatility";
      else
         result.alternative_explanation = "Further investigation recommended";
      
      return result;
   }
   
   //+------------------------------------------------------------------+
   //| Calculate Grade with Confidence Adjustment                       |
   //+------------------------------------------------------------------+
   ENUM_BROKER_GRADE CalculateGrade() {
      SScoreComponents sc = GetScoreBreakdown();
      
      // Adjust score based on confidence
      // Low confidence -> grade closer to neutral (C)
      double adjustedScore = sc.raw_score * sc.confidence + 60.0 * (1.0 - sc.confidence);
      
      if(sc.sample_size < m_minSamp)
         return GRADE_UNKNOWN; // Not enough data
         
      if(adjustedScore >= GRADE_A_MIN) return GRADE_A;
      if(adjustedScore >= GRADE_B_MIN) return GRADE_B;
      if(adjustedScore >= GRADE_C_MIN) return GRADE_C;
      if(adjustedScore >= GRADE_D_MIN) return GRADE_D;
      return GRADE_F;
   }
   
   //+------------------------------------------------------------------+
   //| Get Formatted Report String                                      |
   //+------------------------------------------------------------------+
   string GenerateReport() {
      SScoreComponents sc = GetScoreBreakdown();
      ENUM_BROKER_GRADE grade = CalculateGrade();
      
      string report = "\n=== BROKER INTEGRITY ASSESSMENT ===\n";
      report += StringFormat("Grade: %c\n", EnumToString(grade));
      report += StringFormat("Raw Score: %.1f/100\n", sc.raw_score);
      report += StringFormat("Confidence: %.0f%%\n", sc.confidence * 100);
      report += StringFormat("Evidence Strength: %s\n", 
         sc.evidence_strength > 0.7 ? "STRONG" : 
         sc.evidence_strength > 0.4 ? "MODERATE" : "WEAK");
      report += StringFormat("Sample Size: %d observations\n", sc.sample_size);
      report += StringFormat("Primary Concern: %s\n", sc.primary_concern);
      report += StringFormat("Alternative Explanation: %s\n", sc.alternative_explanation);
      report += "=====================================\n";
      
      return report;
   }
};
#endif

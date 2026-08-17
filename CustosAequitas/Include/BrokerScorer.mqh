#ifndef BROKER_SCORER_MQH
#define BROKER_SCORER_MQH
#include <CustosAequitas\Constants.mqh>
#include <CustosAequitas\SlippageEngine.mqh>
#include <CustosAequitas\LatencyProfiler.mqh>
#include <CustosAequitas\StatisticalCore.mqh>

class CBrokerScorer {
private:
   CSlippageEngine* m_slip; CLatencyProfiler* m_lat; CStatisticalCore* m_stats;
   double m_slipW, m_latW, m_patW; int m_minSamp, m_relSamp, m_confSamp; bool m_adjConf;
   int m_sampleSize;
public:
   CBrokerScorer() { m_slip=NULL; m_lat=NULL; m_stats=NULL; m_slipW=0.4; m_latW=0.4; m_patW=0.2; m_minSamp=30; m_relSamp=50; m_confSamp=100; m_adjConf=true; }
   void SetWeights(double s, double l, double p) { m_slipW=s; m_latW=l; m_patW=p; }
   void SetSampleSizeThresholds(int min, int rel, int conf) { m_minSamp=min; m_relSamp=rel; m_confSamp=conf; }
   void EnableConfidenceAdjustment(bool e) { m_adjConf=e; }
   void SetSlippageEngine(CSlippageEngine* s) { m_slip=s; }
   void SetLatencyProfiler(CLatencyProfiler* l) { m_lat=l; }
   void SetStatisticalCore(CStatisticalCore* st) { m_stats=st; }
   
   double GetCurrentScore() {
      if(!m_slip || !m_lat) return 50.0;
      double slipScore = 100.0 / (1.0 + m_slip.CalculateBiasRatio());
      double latScore = MathMax(0, 100 - m_lat.CalculateAverage()/2);
      return slipScore*m_slipW + latScore*m_latW + 50*m_patW;
   }
   
   ENUM_BROKER_GRADE CalculateGrade() {
      double s = GetCurrentScore();
      if(s >= GRADE_A_MIN) return GRADE_A;
      if(s >= GRADE_B_MIN) return GRADE_B;
      if(s >= GRADE_C_MIN) return GRADE_C;
      if(s >= GRADE_D_MIN) return GRADE_D;
      return GRADE_F;
   }
   
   double GetConfidence() {
      if(!m_slip) return 0;
      int n = m_slip.TotalRecords();
      if(n >= m_confSamp) return 0.95;
      if(n >= m_relSamp) return 0.80;
      if(n >= m_minSamp) return 0.60;
      return n / (double)m_minSamp * 0.6;
   }
};
#endif

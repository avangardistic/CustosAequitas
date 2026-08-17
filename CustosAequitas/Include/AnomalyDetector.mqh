#ifndef ANOMALY_DETECTOR_MQH
#define ANOMALY_DETECTOR_MQH
#include <CustosAequitas\Constants.mqh>
#include <CustosAequitas\SlippageEngine.mqh>
#include <CustosAequitas\LatencyProfiler.mqh>
#include <CustosAequitas\SpreadForensics.mqh>
#include <CustosAequitas\RequoteAnalyzer.mqh>
#include <CustosAequitas\StatisticalCore.mqh>

class CAnomalyDetector {
private:
   CStatisticalCore* m_stats; CSlippageEngine* m_slip; CLatencyProfiler* m_lat; CSpreadForensics* m_spread; CRequoteAnalyzer* m_req;
   double m_fractalDim, m_entropy;
public:
   CAnomalyDetector() { m_stats=NULL; m_slip=NULL; m_lat=NULL; m_spread=NULL; m_req=NULL; m_fractalDim=0.5; m_entropy=0.8; }
   void SetStatisticalCore(CStatisticalCore* s) { m_stats=s; }
   void SetSlippageEngine(CSlippageEngine* s) { m_slip=s; }
   void SetLatencyProfiler(CLatencyProfiler* l) { m_lat=l; }
   void SetSpreadForensics(CSpreadForensics* s) { m_spread=s; }
   void SetRequoteAnalyzer(CRequoteAnalyzer* r) { m_req=r; }
   void SetFractalDimension(double h) { m_fractalDim=h; }
   void SetEntropy(double e) { m_entropy=e; }
   
   ENUM_RISK_LEVEL CheckAnomalies() {
      int riskCount=0;
      if(m_slip && m_slip.CalculateRiskLevel()!=RISK_GREEN) riskCount++;
      if(m_lat && m_lat.GetStatus()!=RISK_GREEN) riskCount++;
      if(riskCount>=2) return RISK_RED;
      if(riskCount==1) return RISK_YELLOW;
      return RISK_GREEN;
   }
};
#endif

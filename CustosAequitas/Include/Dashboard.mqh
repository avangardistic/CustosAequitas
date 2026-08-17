#ifndef DASHBOARD_MQH
#define DASHBOARD_MQH
#include <CustosAequitas\Constants.mqh>
#include <CustosAequitas\SlippageEngine.mqh>
#include <CustosAequitas\LatencyProfiler.mqh>
#include <CustosAequitas\SpreadForensics.mqh>
#include <CustosAequitas\RequoteAnalyzer.mqh>
#include <CustosAequitas\BrokerScorer.mqh>

class CDashboard {
private: bool m_visible; int m_updateSec; CBrokerScorer* m_scorer; CSlippageEngine* m_slip; CLatencyProfiler* m_lat; CSpreadForensics* m_spread; CRequoteAnalyzer* m_req;
public:
   CDashboard() { m_visible=true; m_updateSec=5; m_scorer=NULL; m_slip=NULL; m_lat=NULL; m_spread=NULL; m_req=NULL; }
   void SetVisible(bool v) { m_visible=v; }
   void SetUpdateInterval(int s) { m_updateSec=s; }
   void SetBrokerScorer(CBrokerScorer* s) { m_scorer=s; }
   void SetSlippageEngine(CSlippageEngine* s) { m_slip=s; }
   void SetLatencyProfiler(CLatencyProfiler* l) { m_lat=l; }
   void SetSpreadForensics(CSpreadForensics* s) { m_spread=s; }
   void SetRequoteAnalyzer(CRequoteAnalyzer* r) { m_req=r; }
   void Update() { /* Dashboard rendering logic */ }
};
#endif

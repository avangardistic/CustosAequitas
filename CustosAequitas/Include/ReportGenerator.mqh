#ifndef REPORT_GENERATOR_MQH
#define REPORT_GENERATOR_MQH
#include <CustosAequitas\Constants.mqh>
#include <CustosAequitas\SlippageEngine.mqh>
#include <CustosAequitas\LatencyProfiler.mqh>
#include <CustosAequitas\SpreadForensics.mqh>
#include <CustosAequitas\RequoteAnalyzer.mqh>
#include <CustosAequitas\BrokerScorer.mqh>
#include <CustosAequitas\AnomalyDetector.mqh>

class CReportGenerator {
private: string m_reportDir, m_dataDir; int m_minTrades; CSlippageEngine* m_slip; CLatencyProfiler* m_lat; CSpreadForensics* m_spread; CRequoteAnalyzer* m_req; CBrokerScorer* m_scorer; CAnomalyDetector* m_anom;
public:
   CReportGenerator() { m_reportDir=DEFAULT_REPORT_DIR; m_dataDir=DEFAULT_DATA_DIR; m_minTrades=50; m_slip=NULL; m_lat=NULL; m_spread=NULL; m_req=NULL; m_scorer=NULL; m_anom=NULL; }
   void SetDirectories(string r, string d) { m_reportDir=r; m_dataDir=d; }
   void SetMinTradesForReport(int t) { m_minTrades=t; }
   void SetSlippageEngine(CSlippageEngine* s) { m_slip=s; }
   void SetLatencyProfiler(CLatencyProfiler* l) { m_lat=l; }
   void SetSpreadForensics(CSpreadForensics* s) { m_spread=s; }
   void SetRequoteAnalyzer(CRequoteAnalyzer* r) { m_req=r; }
   void SetBrokerScorer(CBrokerScorer* s) { m_scorer=s; }
   void SetAnomalyDetector(CAnomalyDetector* a) { m_anom=a; }
   
   bool GenerateHTMLReport(const string prefix) { return true; }
   bool ExportCSVData(const string prefix) { return true; }
};
#endif

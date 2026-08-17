#ifndef REQUOTE_ANALYZER_MQH
#define REQUOTE_ANALYZER_MQH
#include <CustosAequitas\Constants.mqh>
class CRequoteAnalyzer {
private: int m_total,m_requotes,m_rejections; double m_warnPct,m_dangerPct; int m_maxRecords;
public:
   CRequoteAnalyzer() { m_total=0; m_requotes=0; m_rejections=0; m_warnPct=DEFAULT_REQUOTE_WARN_PCT; m_dangerPct=DEFAULT_REQUOTE_DANGER_PCT; m_maxRecords=DEFAULT_MAX_RECORDS; }
   void SetThresholds(double w, double d) { m_warnPct=w; m_dangerPct=d; }
   void SetMaxRecords(int m) { m_maxRecords=m; }
   bool RecordTransaction(const MqlTradeTransaction &t, const MqlTradeResult &r) { m_total++; if(r.retcode!=TRADE_RETCODE_DONE) m_rejections++; return true; }
   double GetRequoteRate() { return m_total>0 ? (double)m_requotes/m_total*100 : 0; }
   double GetRejectionRate() { return m_total>0 ? (double)m_rejections/m_total*100 : 0; }
   ENUM_RISK_LEVEL GetStatus() { double r=GetRejectionRate(); if(r>=m_dangerPct) return RISK_RED; if(r>=m_warnPct) return RISK_YELLOW; return RISK_GREEN; }
   int TotalRequests() const { return m_total; }
   bool ExportToCSV(string f) { return true; }
};
#endif

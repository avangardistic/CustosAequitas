//+------------------------------------------------------------------+
//|                                            SpreadForensics.mqh   |
//+------------------------------------------------------------------+
#ifndef SPREAD_FORENSICS_MQH
#define SPREAD_FORENSICS_MQH

#include <CustosAequitas\Constants.mqh>

struct SpreadRecord {
   datetime timestamp;
   long spreadPoints;
   double spreadPips;
   double bid;
   double ask;
};

class CSpreadForensics {
private:
   SpreadRecord m_records[];
   int m_recordCount;
   int m_maxRecords;
   double m_spikeMultiplier;
   
public:
   CSpreadForensics() { m_maxRecords = DEFAULT_MAX_RECORDS; m_spikeMultiplier = DEFAULT_SPREAD_SPIKE_MULT; ArrayResize(m_records, m_maxRecords); }
   ~CSpreadForensics() { ArrayFree(m_records); }
   
   void SetSpikeMultiplier(double mult) { m_spikeMultiplier = mult; }
   void SetMaxRecords(int max) { m_maxRecords = max; }
   
   bool RecordSpread(datetime time, long spreadPts, double bid, double ask) {
      if(m_recordCount >= m_maxRecords) {
         int shift = m_maxRecords/2;
         for(int i=0; i<m_maxRecords-shift; i++) m_records[i] = m_records[i+shift];
         m_recordCount = m_maxRecords - shift;
      }
      m_records[m_recordCount].timestamp = time;
      m_records[m_recordCount].spreadPoints = spreadPts;
      m_records[m_recordCount].spreadPips = spreadPts * SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;
      m_records[m_recordCount].bid = bid;
      m_records[m_recordCount].ask = ask;
      m_recordCount++;
      return true;
   }
   
   double GetAverage() { if(m_recordCount==0) return 0; double sum=0; for(int i=0;i<m_recordCount;i++) sum+=m_records[i].spreadPips; return sum/m_recordCount; }
   ENUM_RISK_LEVEL GetStatus() { return RISK_GREEN; }
   int TotalRecords() const { return m_recordCount; }
   bool ExportToCSV(string f) { return true; }
};
#endif

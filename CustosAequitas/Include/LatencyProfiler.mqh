//+------------------------------------------------------------------+
//|                                            LatencyProfiler.mqh   |
//|                                   Latency Measurement & Analysis |
//+------------------------------------------------------------------+
#ifndef LATENCY_PROFILER_MQH
#define LATENCY_PROFILER_MQH

#include <CustosAequitas\Constants.mqh>

//--- Latency record structure
struct LatencyRecord
{
   datetime timestamp;
   string symbol;
   int operationType;      // 0=OrderSend, 1=OrderModify, 2=OrderClose
   long latencyMs;         // Round-trip latency in milliseconds
   ORDER_SIDE side;
   bool isSuccess;
   int errorCode;
};

//+------------------------------------------------------------------+
//| CLatencyProfiler - Latency measurement engine                     |
//+------------------------------------------------------------------+
class CLatencyProfiler
{
private:
   LatencyRecord m_records[];
   int m_recordCount;
   int m_maxRecords;
   
   int m_warnThresholdMs;
   int m_dangerThresholdMs;
   double m_asymmetryThreshold;
   
   //--- Statistics
   long m_totalLatency;
   int m_successCount;
   int m_failureCount;
   
   //--- BUY/SELL breakdown
   long m_buyTotalLatency;
   int m_buyCount;
   long m_sellTotalLatency;
   int m_sellCount;
   
   //--- Timing
   ulong m_lastStartTime;
   int m_currentOperation;
   
public:
   CLatencyProfiler();
   ~CLatencyProfiler();
   
   //--- Configuration
   void SetThresholds(int warnMs, int dangerMs);
   void SetAsymmetryThreshold(double threshold);
   void SetMaxRecords(int maxRecords);
   
   //--- Measurement
   void StartMeasurement(int operationType);
   void EndMeasurement(bool success = true, int errorCode = 0);
   bool RecordTransaction(const MqlTradeTransaction &trans, 
                          const MqlTradeRequest &request,
                          const MqlTradeResult &result);
   
   //--- Manual recording (for testing)
   bool AddManualRecord(datetime time, string symbol, int opType, long latencyMs);
   
   //--- Statistics
   double CalculateAverage();
   double CalculateMedian();
   long GetMinLatency();
   long GetMaxLatency();
   double CalculatePercentile(double percentile);
   int DetectSpikes(double multiplier = 2.0);
   
   //--- Directional Analysis
   double GetBuyAverage();
   double GetSellAverage();
   bool CheckAsymmetry();
   double GetAsymmetryPercent();
   
   //--- Risk Assessment
   ENUM_RISK_LEVEL GetStatus();
   
   //--- Accessors
   int TotalRecords() const { return m_recordCount; }
   int SuccessCount() const { return m_successCount; }
   int FailureCount() const { return m_failureCount; }
   
   //--- Export
   bool ExportToCSV(const string filename);
   void ClearData();
};

//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CLatencyProfiler::CLatencyProfiler()
{
   m_recordCount = 0;
   m_maxRecords = DEFAULT_MAX_RECORDS;
   m_warnThresholdMs = DEFAULT_LATENCY_WARN_MS;
   m_dangerThresholdMs = DEFAULT_LATENCY_DANGER_MS;
   m_asymmetryThreshold = 20.0;
   
   m_totalLatency = 0;
   m_successCount = 0;
   m_failureCount = 0;
   
   m_buyTotalLatency = 0;
   m_buyCount = 0;
   m_sellTotalLatency = 0;
   m_sellCount = 0;
   
   m_lastStartTime = 0;
   m_currentOperation = -1;
   
   ArrayResize(m_records, m_maxRecords);
}

//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
CLatencyProfiler::~CLatencyProfiler()
{
   ArrayFree(m_records);
}

//+------------------------------------------------------------------+
//| Set thresholds                                                     |
//+------------------------------------------------------------------+
void CLatencyProfiler::SetThresholds(int warnMs, int dangerMs)
{
   m_warnThresholdMs = warnMs;
   m_dangerThresholdMs = dangerMs;
}

//+------------------------------------------------------------------+
//| Set asymmetry threshold                                           |
//+------------------------------------------------------------------+
void CLatencyProfiler::SetAsymmetryThreshold(double threshold)
{
   m_asymmetryThreshold = threshold;
}

//+------------------------------------------------------------------+
//| Set maximum records                                               |
//+------------------------------------------------------------------+
void CLatencyProfiler::SetMaxRecords(int maxRecords)
{
   if(maxRecords < 100) maxRecords = 100;
   
   if(maxRecords != m_maxRecords)
   {
      LatencyRecord temp[];
      ArrayResize(temp, maxRecords);
      
      int copyCount = MathMin(m_recordCount, maxRecords);
      for(int i = 0; i < copyCount; i++)
         temp[i] = m_records[i];
      
      ArrayCopy(m_records, temp);
      m_recordCount = copyCount;
      m_maxRecords = maxRecords;
   }
}

//+------------------------------------------------------------------+
//| Start timing an operation                                         |
//+------------------------------------------------------------------+
void CLatencyProfiler::StartMeasurement(int operationType)
{
   m_lastStartTime = GetMicrosecondCount();
   m_currentOperation = operationType;
}

//+------------------------------------------------------------------+
//| End timing and record result                                      |
//+------------------------------------------------------------------+
void CLatencyProfiler::EndMeasurement(bool success, int errorCode)
{
   if(m_lastStartTime == 0 || m_currentOperation < 0) return;
   
   ulong endTime = GetMicrosecondCount();
   long latencyMs = (long)((endTime - m_lastStartTime) / 1000);
   
   // Create record
   LatencyRecord record;
   record.timestamp = TimeCurrent();
   record.symbol = _Symbol;
   record.operationType = m_currentOperation;
   record.latencyMs = latencyMs;
   record.side = SIDE_UNKNOWN;
   record.isSuccess = success;
   record.errorCode = errorCode;
   
   StoreRecord(record);
   
   m_lastStartTime = 0;
   m_currentOperation = -1;
}

//+------------------------------------------------------------------+
//| Record from trade transaction                                     |
//+------------------------------------------------------------------+
bool CLatencyProfiler::RecordTransaction(const MqlTradeTransaction &trans,
                                          const MqlTradeRequest &request,
                                          const MqlTradeResult &result)
{
   LatencyRecord record;
   record.timestamp = TimeCurrent();
   record.symbol = _Symbol;
   record.operationType = (int)trans.type;
   record.latencyMs = result.retcode == TRADE_RETCODE_DONE ? 
                      (long)((trans.time_ms % 10000)) : 0; // Approximate
   record.side = (request.type == ORDER_TYPE_BUY) ? SIDE_BUY : 
                 (request.type == ORDER_TYPE_SELL) ? SIDE_SELL : SIDE_UNKNOWN;
   record.isSuccess = (result.retcode == TRADE_RETCODE_DONE);
   record.errorCode = (int)result.retcode;
   
   return StoreRecord(record);
}

//+------------------------------------------------------------------+
//| Store a latency record                                            |
//+------------------------------------------------------------------+
bool CLatencyProfiler::StoreRecord(LatencyRecord &record)
{
   if(m_recordCount >= m_maxRecords)
   {
      int shiftAmount = m_maxRecords / 2;
      for(int i = 0; i < m_maxRecords - shiftAmount; i++)
         m_records[i] = m_records[i + shiftAmount];
      m_recordCount = m_maxRecords - shiftAmount;
   }
   
   m_records[m_recordCount] = record;
   m_recordCount++;
   
   // Update statistics
   if(record.isSuccess)
   {
      m_successCount++;
      m_totalLatency += record.latencyMs;
      
      if(record.side == SIDE_BUY)
      {
         m_buyCount++;
         m_buyTotalLatency += record.latencyMs;
      }
      else if(record.side == SIDE_SELL)
      {
         m_sellCount++;
         m_sellTotalLatency += record.latencyMs;
      }
   }
   else
   {
      m_failureCount++;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Add manual record (for testing)                                   |
//+------------------------------------------------------------------+
bool CLatencyProfiler::AddManualRecord(datetime time, string symbol, 
                                        int opType, long latencyMs)
{
   LatencyRecord record;
   record.timestamp = time;
   record.symbol = symbol;
   record.operationType = opType;
   record.latencyMs = latencyMs;
   record.side = SIDE_UNKNOWN;
   record.isSuccess = (latencyMs > 0);
   record.errorCode = 0;
   
   return StoreRecord(record);
}

//+------------------------------------------------------------------+
//| Calculate average latency                                         |
//+------------------------------------------------------------------+
double CLatencyProfiler::CalculateAverage()
{
   if(m_successCount == 0) return 0.0;
   return (double)m_totalLatency / m_successCount;
}

//+------------------------------------------------------------------+
//| Calculate median latency                                          |
//+------------------------------------------------------------------+
double CLatencyProfiler::CalculateMedian()
{
   if(m_recordCount == 0) return 0.0;
   
   double values[];
   ArrayResize(values, m_recordCount);
   
   for(int i = 0; i < m_recordCount; i++)
      values[i] = (double)m_records[i].latencyMs;
   
   ArraySort(values);
   
   if(m_recordCount % 2 == 0)
      return (values[m_recordCount/2 - 1] + values[m_recordCount/2]) / 2.0;
   else
      return values[m_recordCount/2];
}

//+------------------------------------------------------------------+
//| Get minimum latency                                               |
//+------------------------------------------------------------------+
long CLatencyProfiler::GetMinLatency()
{
   if(m_recordCount == 0) return 0;
   
   long minVal = m_records[0].latencyMs;
   for(int i = 1; i < m_recordCount; i++)
      if(m_records[i].latencyMs < minVal) minVal = m_records[i].latencyMs;
   
   return minVal;
}

//+------------------------------------------------------------------+
//| Get maximum latency                                               |
//+------------------------------------------------------------------+
long CLatencyProfiler::GetMaxLatency()
{
   if(m_recordCount == 0) return 0;
   
   long maxVal = m_records[0].latencyMs;
   for(int i = 1; i < m_recordCount; i++)
      if(m_records[i].latencyMs > maxVal) maxVal = m_records[i].latencyMs;
   
   return maxVal;
}

//+------------------------------------------------------------------+
//| Calculate percentile                                              |
//+------------------------------------------------------------------+
double CLatencyProfiler::CalculatePercentile(double percentile)
{
   if(m_recordCount == 0) return 0.0;
   
   double values[];
   ArrayResize(values, m_recordCount);
   
   for(int i = 0; i < m_recordCount; i++)
      values[i] = (double)m_records[i].latencyMs;
   
   ArraySort(values);
   
   double index = (percentile / 100.0) * (m_recordCount - 1);
   int lower = (int)MathFloor(index);
   int upper = (int)MathCeil(index);
   
   if(lower == upper || upper >= m_recordCount)
      return values[lower];
   
   double fraction = index - lower;
   return values[lower] + fraction * (values[upper] - values[lower]);
}

//+------------------------------------------------------------------+
//| Detect latency spikes                                             |
//+------------------------------------------------------------------+
int CLatencyProfiler::DetectSpikes(double multiplier)
{
   if(m_recordCount < 10) return 0;
   
   double avg = CalculateAverage();
   double threshold = avg * multiplier;
   
   int spikeCount = 0;
   for(int i = 0; i < m_recordCount; i++)
   {
      if(m_records[i].latencyMs > threshold)
         spikeCount++;
   }
   
   return spikeCount;
}

//+------------------------------------------------------------------+
//| Get BUY average latency                                           |
//+------------------------------------------------------------------+
double CLatencyProfiler::GetBuyAverage()
{
   if(m_buyCount == 0) return 0.0;
   return (double)m_buyTotalLatency / m_buyCount;
}

//+------------------------------------------------------------------+
//| Get SELL average latency                                          |
//+------------------------------------------------------------------+
double CLatencyProfiler::GetSellAverage()
{
   if(m_sellCount == 0) return 0.0;
   return (double)m_sellTotalLatency / m_sellCount;
}

//+------------------------------------------------------------------+
//| Check for BUY/SELL asymmetry                                      |
//+------------------------------------------------------------------+
bool CLatencyProfiler::CheckAsymmetry()
{
   double buyAvg = GetBuyAverage();
   double sellAvg = GetSellAverage();
   
   if(buyAvg < 1 || sellAvg < 1) return false;
   
   double diff = MathAbs(buyAvg - sellAvg);
   double avgOverall = (buyAvg + sellAvg) / 2.0;
   
   return (diff / avgOverall * 100.0) > m_asymmetryThreshold;
}

//+------------------------------------------------------------------+
//| Get asymmetry percentage                                          |
//+------------------------------------------------------------------+
double CLatencyProfiler::GetAsymmetryPercent()
{
   double buyAvg = GetBuyAverage();
   double sellAvg = GetSellAverage();
   
   if(buyAvg < 1 && sellAvg < 1) return 0.0;
   
   double diff = MathAbs(buyAvg - sellAvg);
   double avgOverall = (buyAvg + sellAvg) / 2.0;
   
   return (diff / avgOverall * 100.0);
}

//+------------------------------------------------------------------+
//| Get risk status                                                   |
//+------------------------------------------------------------------+
ENUM_RISK_LEVEL CLatencyProfiler::GetStatus()
{
   double avg = CalculateAverage();
   
   if(avg >= m_dangerThresholdMs) return RISK_RED;
   if(avg >= m_warnThresholdMs) return RISK_YELLOW;
   if(CheckAsymmetry()) return RISK_YELLOW;
   
   return RISK_GREEN;
}

//+------------------------------------------------------------------+
//| Export to CSV                                                     |
//+------------------------------------------------------------------+
bool CLatencyProfiler::ExportToCSV(const string filename)
{
   int handle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_ANSI, ";");
   if(handle == INVALID_HANDLE) return false;
   
   FileWrite(handle, "Timestamp", "Symbol", "OperationType", "LatencyMs", 
             "Side", "IsSuccess", "ErrorCode");
   
   for(int i = 0; i < m_recordCount; i++)
   {
      FileWrite(handle,
                TimeToString(m_records[i].timestamp),
                m_records[i].symbol,
                m_records[i].operationType,
                m_records[i].latencyMs,
                (m_records[i].side == SIDE_BUY) ? "BUY" : 
                (m_records[i].side == SIDE_SELL) ? "SELL" : "UNKNOWN",
                m_records[i].isSuccess ? "true" : "false",
                m_records[i].errorCode);
   }
   
   FileClose(handle);
   return true;
}

//+------------------------------------------------------------------+
//| Clear all data                                                    |
//+------------------------------------------------------------------+
void CLatencyProfiler::ClearData()
{
   m_recordCount = 0;
   m_totalLatency = 0;
   m_successCount = 0;
   m_failureCount = 0;
   m_buyTotalLatency = 0;
   m_buyCount = 0;
   m_sellTotalLatency = 0;
   m_sellCount = 0;
}

#endif // LATENCY_PROFILER_MQH

//+------------------------------------------------------------------+
//|                                            SlippageEngine.mqh    |
//|                                   Slippage Analysis & Recording  |
//+------------------------------------------------------------------+
#ifndef SLIPPAGE_ENGINE_MQH
#define SLIPPAGE_ENGINE_MQH

#include <CustosAequitas\Constants.mqh>

//--- Slippage record structure
struct SlippageRecord
{
   datetime timestamp;
   string symbol;
   ORDER_SIDE side;
   double requestedPrice;
   double fillPrice;
   double slippage;        // In points
   double slippagePips;    // In pips
   bool isPositive;        // Favorable slippage
   long dealTicket;
   ulong orderTicket;
   ENUM_DEAL_TYPE dealType;
};

//+------------------------------------------------------------------+
//| CSlippageEngine - Slippage analysis engine                        |
//+------------------------------------------------------------------+
class CSlippageEngine
{
private:
   SlippageRecord m_records[];
   int m_recordCount;
   int m_maxRecords;
   
   double m_warningThreshold;
   double m_dangerThreshold;
   
   //--- Counters
   int m_positiveCount;
   int m_negativeCount;
   double m_totalPositiveSlippage;
   double m_totalNegativeSlippage;
   
   //--- BUY/SELL breakdown
   int m_buyPositiveCount;
   int m_buyNegativeCount;
   int m_sellPositiveCount;
   int m_sellNegativeCount;
   
public:
   CSlippageEngine();
   ~CSlippageEngine();
   
   //--- Configuration
   void SetThresholds(double warning, double danger);
   void SetMaxRecords(int maxRecords);
   
   //--- Data Recording
   bool RecordDeal(const MqlTradeTransaction &trans, const MqlTradeResult &result);
   bool AddManualRecord(datetime time, string symbol, ORDER_SIDE side, 
                        double reqPrice, double fillPrice);
   
   //--- Statistics
   double CalculateBiasRatio();           // Negative count / Positive count
   double CalculateMagnitudeRatio();      // Avg neg / Avg pos slippage
   double GetAverageSlippage();
   double GetAveragePositiveSlippage();
   double GetAverageNegativeSlippage();
   
   //--- Directional Analysis
   double GetBuyBiasRatio();
   double GetSellBiasRatio();
   bool HasDirectionalBias(double threshold = 1.5);
   
   //--- Risk Assessment
   ENUM_RISK_LEVEL CalculateRiskLevel();
   ENUM_EVIDENCE_STRENGTH GetEvidenceStrength();
   
   //--- Accessors
   int TotalRecords() const { return m_recordCount; }
   int PositiveCount() const { return m_positiveCount; }
   int NegativeCount() const { return m_negativeCount; }
   const SlippageRecord& GetRecord(int index) const;
   
   //--- Export
   bool ExportToCSV(const string filename);
   void ClearData();
};

//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CSlippageEngine::CSlippageEngine()
{
   m_recordCount = 0;
   m_maxRecords = DEFAULT_MAX_RECORDS;
   m_warningThreshold = DEFAULT_SLIPPAGE_WARNING;
   m_dangerThreshold = DEFAULT_SLIPPAGE_DANGER;
   
   m_positiveCount = 0;
   m_negativeCount = 0;
   m_totalPositiveSlippage = 0;
   m_totalNegativeSlippage = 0;
   
   m_buyPositiveCount = 0;
   m_buyNegativeCount = 0;
   m_sellPositiveCount = 0;
   m_sellNegativeCount = 0;
   
   ArrayResize(m_records, m_maxRecords);
}

//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
CSlippageEngine::~CSlippageEngine()
{
   ArrayFree(m_records);
}

//+------------------------------------------------------------------+
//| Set thresholds                                                     |
//+------------------------------------------------------------------+
void CSlippageEngine::SetThresholds(double warning, double danger)
{
   m_warningThreshold = warning;
   m_dangerThreshold = danger;
}

//+------------------------------------------------------------------+
//| Set maximum records                                                |
//+------------------------------------------------------------------+
void CSlippageEngine::SetMaxRecords(int maxRecords)
{
   if(maxRecords < 100) maxRecords = 100;
   
   if(maxRecords != m_maxRecords)
   {
      SlippageRecord temp[];
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
//| Record a deal transaction                                         |
//+------------------------------------------------------------------+
bool CSlippageEngine::RecordDeal(const MqlTradeTransaction &trans, const MqlTradeResult &result)
{
   if(trans.deal == 0) return false;
   if(result.order == 0) return false;
   
   // Get order details
   MqlOrder order;
   if(!OrderSelect(trans.order, SELECT_BY_TICKET)) return false;
   
   // Only process market orders for slippage analysis
   if(order.Type() != ORDER_TYPE_BUY && order.Type() != ORDER_TYPE_SELL)
      return false;
   
   // Determine side
   ORDER_SIDE side = (order.Type() == ORDER_TYPE_BUY) ? SIDE_BUY : SIDE_SELL;
   
   // Calculate slippage
   double requestedPrice = order.PriceOpen();
   double fillPrice = result.price;
   
   double slippagePoints = 0;
   if(side == SIDE_BUY)
      slippagePoints = fillPrice - requestedPrice;  // Positive = worse for buy
   else
      slippagePoints = requestedPrice - fillPrice;  // Positive = worse for sell
   
   // Convert to pips (approximate)
   double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double pipValue = pointValue * 10; // Standard pip
   double slippagePips = slippagePoints / pipValue;
   
   // Determine if positive (favorable) or negative (unfavorable)
   bool isPositive = (slippagePips > 0);
   
   // Create record
   SlippageRecord record;
   record.timestamp = TimeCurrent();
   record.symbol = _Symbol;
   record.side = side;
   record.requestedPrice = requestedPrice;
   record.fillPrice = fillPrice;
   record.slippage = slippagePoints;
   record.slippagePips = slippagePips;
   record.isPositive = isPositive;
   record.dealTicket = trans.deal;
   record.orderTicket = trans.order;
   record.dealType = trans.type;
   
   // Store record
   if(m_recordCount >= m_maxRecords)
   {
      // Shift data
      int shiftAmount = m_maxRecords / 2;
      for(int i = 0; i < m_maxRecords - shiftAmount; i++)
         m_records[i] = m_records[i + shiftAmount];
      m_recordCount = m_maxRecords - shiftAmount;
   }
   
   m_records[m_recordCount] = record;
   m_recordCount++;
   
   // Update counters
   if(isPositive)
   {
      m_positiveCount++;
      m_totalPositiveSlippage += MathAbs(slippagePips);
      if(side == SIDE_BUY) m_buyPositiveCount++;
      else m_sellPositiveCount++;
   }
   else
   {
      m_negativeCount++;
      m_totalNegativeSlippage += MathAbs(slippagePips);
      if(side == SIDE_BUY) m_buyNegativeCount++;
      else m_sellNegativeCount++;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Add manual record (for testing)                                   |
//+------------------------------------------------------------------+
bool CSlippageEngine::AddManualRecord(datetime time, string symbol, ORDER_SIDE side,
                                       double reqPrice, double fillPrice)
{
   double slippagePips = (fillPrice - reqPrice) * 10000; // Approximate pips
   if(side == SIDE_SELL) slippagePips = -slippagePips;
   
   bool isPositive = (slippagePips > 0);
   
   SlippageRecord record;
   record.timestamp = time;
   record.symbol = symbol;
   record.side = side;
   record.requestedPrice = reqPrice;
   record.fillPrice = fillPrice;
   record.slippage = slippagePips / 10000;
   record.slippagePips = slippagePips;
   record.isPositive = isPositive;
   record.dealTicket = 0;
   record.orderTicket = 0;
   record.dealType = DEAL_ENTRY_IN;
   
   if(m_recordCount >= m_maxRecords)
   {
      int shiftAmount = m_maxRecords / 2;
      for(int i = 0; i < m_maxRecords - shiftAmount; i++)
         m_records[i] = m_records[i + shiftAmount];
      m_recordCount = m_maxRecords - shiftAmount;
   }
   
   m_records[m_recordCount] = record;
   m_recordCount++;
   
   if(isPositive)
   {
      m_positiveCount++;
      m_totalPositiveSlippage += MathAbs(slippagePips);
      if(side == SIDE_BUY) m_buyPositiveCount++;
      else m_sellPositiveCount++;
   }
   else
   {
      m_negativeCount++;
      m_totalNegativeSlippage += MathAbs(slippagePips);
      if(side == SIDE_BUY) m_buyNegativeCount++;
      else m_sellNegativeCount++;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate bias ratio (negative count / positive count)            |
//+------------------------------------------------------------------+
double CSlippageEngine::CalculateBiasRatio()
{
   if(m_positiveCount == 0)
   {
      if(m_negativeCount == 0) return 1.0; // No data = neutral
      return 10.0; // All negative = severe bias
   }
   
   return (double)m_negativeCount / m_positiveCount;
}

//+------------------------------------------------------------------+
//| Calculate magnitude ratio (avg negative / avg positive)           |
//+------------------------------------------------------------------+
double CSlippageEngine::CalculateMagnitudeRatio()
{
   if(m_positiveCount == 0 || m_negativeCount == 0) return 1.0;
   
   double avgPositive = m_totalPositiveSlippage / m_positiveCount;
   double avgNegative = m_totalNegativeSlippage / m_negativeCount;
   
   if(avgPositive < 0.0001) return 1.0;
   
   return avgNegative / avgPositive;
}

//+------------------------------------------------------------------+
//| Get average slippage                                              |
//+------------------------------------------------------------------+
double CSlippageEngine::GetAverageSlippage()
{
   if(m_recordCount == 0) return 0.0;
   
   double total = m_totalPositiveSlippage - m_totalNegativeSlippage;
   return total / m_recordCount;
}

//+------------------------------------------------------------------+
//| Get average positive slippage                                     |
//+------------------------------------------------------------------+
double CSlippageEngine::GetAveragePositiveSlippage()
{
   if(m_positiveCount == 0) return 0.0;
   return m_totalPositiveSlippage / m_positiveCount;
}

//+------------------------------------------------------------------+
//| Get average negative slippage                                     |
//+------------------------------------------------------------------+
double CSlippageEngine::GetAverageNegativeSlippage()
{
   if(m_negativeCount == 0) return 0.0;
   return m_totalNegativeSlippage / m_negativeCount;
}

//+------------------------------------------------------------------+
//| Get BUY bias ratio                                                |
//+------------------------------------------------------------------+
double CSlippageEngine::GetBuyBiasRatio()
{
   if(m_buyPositiveCount == 0)
   {
      if(m_buyNegativeCount == 0) return 1.0;
      return 10.0;
   }
   return (double)m_buyNegativeCount / m_buyPositiveCount;
}

//+------------------------------------------------------------------+
//| Get SELL bias ratio                                               |
//+------------------------------------------------------------------+
double CSlippageEngine::GetSellBiasRatio()
{
   if(m_sellPositiveCount == 0)
   {
      if(m_sellNegativeCount == 0) return 1.0;
      return 10.0;
   }
   return (double)m_sellNegativeCount / m_sellPositiveCount;
}

//+------------------------------------------------------------------+
//| Check for directional bias                                        |
//+------------------------------------------------------------------+
bool CSlippageEngine::HasDirectionalBias(double threshold)
{
   double buyBias = GetBuyBiasRatio();
   double sellBias = GetSellBiasRatio();
   
   return (buyBias > threshold || sellBias > threshold ||
           MathAbs(buyBias - sellBias) > 0.5);
}

//+------------------------------------------------------------------+
//| Calculate risk level                                              |
//+------------------------------------------------------------------+
ENUM_RISK_LEVEL CSlippageEngine::CalculateRiskLevel()
{
   double ratio = CalculateBiasRatio();
   
   if(ratio >= m_dangerThreshold) return RISK_RED;
   if(ratio >= m_warningThreshold) return RISK_YELLOW;
   return RISK_GREEN;
}

//+------------------------------------------------------------------+
//| Get evidence strength based on sample size and effect             |
//+------------------------------------------------------------------+
ENUM_EVIDENCE_STRENGTH CSlippageEngine::GetEvidenceStrength()
{
   if(m_recordCount < MIN_SAMPLES_PRELIMINARY)
      return EVIDENCE_INSUFFICIENT;
   
   double ratio = CalculateBiasRatio();
   double magnitude = CalculateMagnitudeRatio();
   
   // Strong evidence requires both high ratio AND large sample
   if(m_recordCount >= MIN_SAMPLES_HIGH_CONFIDENCE && ratio >= m_dangerThreshold)
      return EVIDENCE_VERY_STRONG;
   
   if(m_recordCount >= MIN_SAMPLES_RELIABLE && ratio >= m_warningThreshold)
      return EVIDENCE_STRONG;
   
   if(m_recordCount >= MIN_SAMPLES_PRELIMINARY && ratio >= m_warningThreshold)
      return EVIDENCE_MODERATE;
   
   return EVIDENCE_WEAK;
}

//+------------------------------------------------------------------+
//| Get record by index                                               |
//+------------------------------------------------------------------+
const SlippageRecord& CSlippageEngine::GetRecord(int index) const
{
   static SlippageRecord empty;
   if(index < 0 || index >= m_recordCount) return empty;
   return m_records[index];
}

//+------------------------------------------------------------------+
//| Export to CSV file                                                |
//+------------------------------------------------------------------+
bool CSlippageEngine::ExportToCSV(const string filename)
{
   int handle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_ANSI, ";");
   if(handle == INVALID_HANDLE) return false;
   
   // Header
   FileWrite(handle, "Timestamp", "Symbol", "Side", "RequestedPrice", "FillPrice",
             "SlippagePoints", "SlippagePips", "IsPositive", "DealTicket");
   
   // Data
   for(int i = 0; i < m_recordCount; i++)
   {
      FileWrite(handle,
                TimeToString(m_records[i].timestamp),
                m_records[i].symbol,
                (m_records[i].side == SIDE_BUY) ? "BUY" : "SELL",
                m_records[i].requestedPrice,
                m_records[i].fillPrice,
                m_records[i].slippage,
                m_records[i].slippagePips,
                m_records[i].isPositive ? "true" : "false",
                m_records[i].dealTicket);
   }
   
   FileClose(handle);
   return true;
}

//+------------------------------------------------------------------+
//| Clear all data                                                    |
//+------------------------------------------------------------------+
void CSlippageEngine::ClearData()
{
   m_recordCount = 0;
   m_positiveCount = 0;
   m_negativeCount = 0;
   m_totalPositiveSlippage = 0;
   m_totalNegativeSlippage = 0;
   m_buyPositiveCount = 0;
   m_buyNegativeCount = 0;
   m_sellPositiveCount = 0;
   m_sellNegativeCount = 0;
}

#endif // SLIPPAGE_ENGINE_MQH

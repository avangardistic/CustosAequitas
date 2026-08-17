//+------------------------------------------------------------------+
//|                                            StatisticalCore.mqh   |
//|                                   Core Statistical Functions     |
//+------------------------------------------------------------------+
#ifndef STATISTICAL_CORE_MQH
#define STATISTICAL_CORE_MQH

#include <CustosAequitas\Constants.mqh>

//+------------------------------------------------------------------+
//| CStatisticalCore - Pure statistical calculations                  |
//| Purpose: Isolate mathematical functions for testability           |
//+------------------------------------------------------------------+
class CStatisticalCore
{
private:
   double m_confidenceLevel;
   int m_fractalKMax;
   int m_entropyEmbeddingDim;
   
   //--- Data buffers for analysis
   double m_tickData[];
   int m_tickCount;
   int m_maxTicks;
   
   //--- Precomputed values
   bool m_initialized;
   
public:
   CStatisticalCore();
   ~CStatisticalCore();
   
   //--- Initialization
   bool Initialize(double confidenceLevel, int fractalKMax, int embeddingDim);
   
   //--- Basic Statistics (Pure Functions)
   static double CalculateMean(const double &data[]);
   static double CalculateMedian(double &data[]);
   static double CalculateVariance(const double &data[], double mean = 0);
   static double CalculateStdDev(const double &data[], double mean = 0);
   static double CalculateMAD(const double &data[], double median = 0);
   static double CalculatePercentile(double &data[], double percentile);
   static double CalculateMin(const double &data[]);
   static double CalculateMax(const double &data[]);
   
   //--- Advanced Statistics
   double CalculateHurstExponent();
   double CalculatePermutationEntropy();
   double CalculateFractalDimension();
   
   //--- Statistical Tests
   static double TTest(const double &sample1[], const double &sample2[]);
   static double ChiSquare(const double &observed[], const double &expected[]);
   static double MannWhitneyU(const double &sample1[], const double &sample2[]);
   
   //--- Confidence Intervals
   bool CalculateConfidenceInterval(const double &data[], double &lower, double &upper, double confidence = 0.95);
   
   //--- Data Management
   void AddTick(double bid, double ask);
   void ClearData();
   int GetDataCount() const { return m_tickCount; }
   
   //--- Getters
   double GetConfidenceLevel() const { return m_confidenceLevel; }
   int GetFractalKMax() const { return m_fractalKMax; }
   int GetEmbeddingDim() const { return m_entropyEmbeddingDim; }
};

//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CStatisticalCore::CStatisticalCore()
{
   m_confidenceLevel = DEFAULT_CONFIDENCE_LEVEL;
   m_fractalKMax = 10;
   m_entropyEmbeddingDim = 3;
   m_tickCount = 0;
   m_maxTicks = 10000;
   m_initialized = false;
   
   ArrayResize(m_tickData, m_maxTicks);
   ArrayInitialize(m_tickData, 0.0);
}

//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
CStatisticalCore::~CStatisticalCore()
{
   ArrayFree(m_tickData);
}

//+------------------------------------------------------------------+
//| Initialize statistical core                                       |
//+------------------------------------------------------------------+
bool CStatisticalCore::Initialize(double confidenceLevel, int fractalKMax, int embeddingDim)
{
   if(confidenceLevel <= 0 || confidenceLevel >= 1) return false;
   if(fractalKMax < 3 || fractalKMax > 20) return false;
   if(embeddingDim < 2 || embeddingDim > 10) return false;
   
   m_confidenceLevel = confidenceLevel;
   m_fractalKMax = fractalKMax;
   m_entropyEmbeddingDim = embeddingDim;
   m_initialized = true;
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate arithmetic mean                                         |
//+------------------------------------------------------------------+
double CStatisticalCore::CalculateMean(const double &data[])
{
   int size = ArraySize(data);
   if(size == 0) return 0.0;
   
   double sum = 0.0;
   for(int i = 0; i < size; i++)
      sum += data[i];
   
   return sum / size;
}

//+------------------------------------------------------------------+
//| Calculate median                                                  |
//+------------------------------------------------------------------+
double CStatisticalCore::CalculateMedian(double &data[])
{
   int size = ArraySize(data);
   if(size == 0) return 0.0;
   
   ArraySort(data);
   
   if(size % 2 == 0)
      return (data[size/2 - 1] + data[size/2]) / 2.0;
   else
      return data[size/2];
}

//+------------------------------------------------------------------+
//| Calculate variance                                                 |
//+------------------------------------------------------------------+
double CStatisticalCore::CalculateVariance(const double &data[], double mean)
{
   int size = ArraySize(data);
   if(size < 2) return 0.0;
   
   if(mean == 0) mean = CalculateMean(data);
   
   double sum = 0.0;
   for(int i = 0; i < size; i++)
   {
      double diff = data[i] - mean;
      sum += diff * diff;
   }
   
   return sum / (size - 1); // Sample variance
}

//+------------------------------------------------------------------+
//| Calculate standard deviation                                      |
//+------------------------------------------------------------------+
double CStatisticalCore::CalculateStdDev(const double &data[], double mean)
{
   return MathSqrt(CalculateVariance(data, mean));
}

//+------------------------------------------------------------------+
//| Calculate Mean Absolute Deviation                                 |
//+------------------------------------------------------------------+
double CStatisticalCore::CalculateMAD(const double &data[], double median)
{
   int size = ArraySize(data);
   if(size == 0) return 0.0;
   
   if(median == 0) 
   {
      double temp[];
      ArrayCopy(temp, data);
      median = CalculateMedian(temp);
   }
   
   double sum = 0.0;
   for(int i = 0; i < size; i++)
      sum += MathAbs(data[i] - median);
   
   return sum / size;
}

//+------------------------------------------------------------------+
//| Calculate percentile                                              |
//+------------------------------------------------------------------+
double CStatisticalCore::CalculatePercentile(double &data[], double percentile)
{
   int size = ArraySize(data);
   if(size == 0) return 0.0;
   
   ArraySort(data);
   
   double index = (percentile / 100.0) * (size - 1);
   int lower = (int)MathFloor(index);
   int upper = (int)MathCeil(index);
   
   if(lower == upper || upper >= size)
      return data[lower];
   
   double fraction = index - lower;
   return data[lower] + fraction * (data[upper] - data[lower]);
}

//+------------------------------------------------------------------+
//| Calculate minimum value                                           |
//+------------------------------------------------------------------+
double CStatisticalCore::CalculateMin(const double &data[])
{
   int size = ArraySize(data);
   if(size == 0) return 0.0;
   
   double minVal = data[0];
   for(int i = 1; i < size; i++)
      if(data[i] < minVal) minVal = data[i];
   
   return minVal;
}

//+------------------------------------------------------------------+
//| Calculate maximum value                                           |
//+------------------------------------------------------------------+
double CStatisticalCore::CalculateMax(const double &data[])
{
   int size = ArraySize(data);
   if(size == 0) return 0.0;
   
   double maxVal = data[0];
   for(int i = 1; i < size; i++)
      if(data[i] > maxVal) maxVal = data[i];
   
   return maxVal;
}

//+------------------------------------------------------------------+
//| Calculate Hurst Exponent using Rescaled Range (R/S) Analysis      |
//| Note: Simplified Higuchi-like method                              |
//+------------------------------------------------------------------+
double CStatisticalCore::CalculateHurstExponent()
{
   if(m_tickCount < 100) return 0.5; // Insufficient data
   
   // Prepare returns series
   double returns[];
   ArrayResize(returns, m_tickCount - 1);
   
   for(int i = 1; i < m_tickCount; i++)
      returns[i-1] = m_tickData[i] - m_tickData[i-1];
   
   // R/S analysis with multiple time scales
   int scales[] = {10, 20, 50, 100, 200};
   int numScales = ArraySize(scales);
   
   double logN[], logRS[];
   ArrayResize(logN, numScales);
   ArrayResize(logRS, numScales);
   
   int validPoints = 0;
   
   for(int s = 0; s < numScales; s++)
   {
      int n = scales[s];
      if(n >= m_tickCount - 1) continue;
      
      // Calculate R/S for this scale
      double rs = CalculateRSForScale(returns, n);
      if(rs > 0)
      {
         logN[validPoints] = MathLog(n);
         logRS[validPoints] = MathLog(rs);
         validPoints++;
      }
   }
   
   if(validPoints < 2) return 0.5;
   
   // Linear regression to estimate H
   double H = EstimateSlope(logN, logRS, validPoints);
   
   return MathMax(0.0, MathMin(1.0, H)); // Clamp to [0, 1]
}

//+------------------------------------------------------------------+
//| Helper: Calculate R/S for a given scale                          |
//+------------------------------------------------------------------+
double CStatisticalCore::CalculateRSForScale(const double &data[], int n)
{
   int numSegments = ArraySize(data) / n;
   if(numSegments < 1) return 0.0;
   
   double totalRS = 0.0;
   
   for(int seg = 0; seg < numSegments; seg++)
   {
      int start = seg * n;
      
      // Calculate mean of segment
      double mean = 0;
      for(int i = 0; i < n; i++)
         mean += data[start + i];
      mean /= n;
      
      // Calculate cumulative deviation
      double cumDev[];
      ArrayResize(cumDev, n);
      
      cumDev[0] = data[start] - mean;
      for(int i = 1; i < n; i++)
         cumDev[i] = cumDev[i-1] + (data[start + i] - mean);
      
      // R = range of cumulative deviations
      double R = CalculateMax(cumDev) - CalculateMin(cumDev);
      
      // S = standard deviation
      double S = CalculateStdDev(data, start, n, mean);
      
      if(S > 0)
         totalRS += R / S;
   }
   
   return totalRS / numSegments;
}

//+------------------------------------------------------------------+
//| Helper: Calculate std dev for subset                             |
//+------------------------------------------------------------------+
double CStatisticalCore::CalculateStdDev(const double &data[], int start, int count, double mean)
{
   double sum = 0.0;
   for(int i = 0; i < count; i++)
   {
      double diff = data[start + i] - mean;
      sum += diff * diff;
   }
   return MathSqrt(sum / (count - 1));
}

//+------------------------------------------------------------------+
//| Helper: Estimate slope from linear regression                    |
//+------------------------------------------------------------------+
double CStatisticalCore::EstimateSlope(const double &x[], const double &y[], int count)
{
   if(count < 2) return 0.0;
   
   double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
   
   for(int i = 0; i < count; i++)
   {
      sumX += x[i];
      sumY += y[i];
      sumXY += x[i] * y[i];
      sumX2 += x[i] * x[i];
   }
   
   double denominator = count * sumX2 - sumX * sumX;
   if(MathAbs(denominator) < 1e-10) return 0.0;
   
   return (count * sumXY - sumX * sumY) / denominator;
}

//+------------------------------------------------------------------+
//| Calculate Permutation Entropy                                     |
//+------------------------------------------------------------------+
double CStatisticalEntropy()
{
   // Placeholder - full implementation would compute permutation patterns
   // and calculate Shannon entropy over the pattern distribution
   return 0.8; // Default reasonable value
}

double CStatisticalCore::CalculatePermutationEntropy()
{
   if(m_tickCount < m_entropyEmbeddingDim * 10) return 0.0;
   
   // Simplified permutation entropy calculation
   // Full implementation would:
   // 1. Create embedding vectors
   // 2. Determine ordinal patterns
   // 3. Count pattern frequencies
   // 4. Calculate Shannon entropy
   
   int factorial = 1;
   for(int i = 2; i <= m_entropyEmbeddingDim; i++)
      factorial *= i;
   
   double maxEntropy = MathLog(factorial);
   
   // Placeholder calculation
   double currentEntropy = maxEntropy * 0.8;
   
   return currentEntropy / maxEntropy; // Normalized to [0, 1]
}

//+------------------------------------------------------------------+
//| Calculate Fractal Dimension                                       |
//+------------------------------------------------------------------+
double CStatisticalCore::CalculateFractalDimension()
{
   // Box-counting dimension approximation
   double H = CalculateHurstExponent();
   return 2.0 - H; // Relationship between H and fractal dimension
}

//+------------------------------------------------------------------+
//| Two-sample t-test                                                 |
//+------------------------------------------------------------------+
double CStatisticalCore::TTest(const double &sample1[], const double &sample2[])
{
   int n1 = ArraySize(sample1);
   int n2 = ArraySize(sample2);
   
   if(n1 < 2 || n2 < 2) return 0.0;
   
   double mean1 = CalculateMean(sample1);
   double mean2 = CalculateMean(sample2);
   
   double var1 = CalculateVariance(sample1, mean1);
   double var2 = CalculateVariance(sample2, mean2);
   
   // Pooled standard error
   double se = MathSqrt(var1/n1 + var2/n2);
   if(se < 1e-10) return 0.0;
   
   double t = (mean1 - mean2) / se;
   
   return t;
}

//+------------------------------------------------------------------+
//| Chi-square test                                                   |
//+------------------------------------------------------------------+
double CStatisticalCore::ChiSquare(const double &observed[], const double &expected[])
{
   int n = ArraySize(observed);
   if(n != ArraySize(expected)) return 0.0;
   
   double chi2 = 0.0;
   for(int i = 0; i < n; i++)
   {
      if(expected[i] > 0)
      {
         double diff = observed[i] - expected[i];
         chi2 += (diff * diff) / expected[i];
      }
   }
   
   return chi2;
}

//+------------------------------------------------------------------+
//| Mann-Whitney U test                                               |
//+------------------------------------------------------------------+
double CStatisticalCore::MannWhitneyU(const double &sample1[], const double &sample2[])
{
   // Simplified implementation
   // Full implementation would rank all observations together
   // and calculate U statistic
   
   int n1 = ArraySize(sample1);
   int n2 = ArraySize(sample2);
   
   if(n1 < 1 || n2 < 1) return 0.0;
   
   // Count how many times sample1 values exceed sample2 values
   int u1 = 0;
   for(int i = 0; i < n1; i++)
   {
      for(int j = 0; j < n2; j++)
      {
         if(sample1[i] > sample2[j]) u1++;
      }
   }
   
   return (double)u1 / (n1 * n2); // Normalized U
}

//+------------------------------------------------------------------+
//| Calculate confidence interval                                     |
//+------------------------------------------------------------------+
bool CStatisticalCore::CalculateConfidenceInterval(const double &data[], 
                                                    double &lower, double &upper, 
                                                    double confidence)
{
   int n = ArraySize(data);
   if(n < 2) return false;
   
   double mean = CalculateMean(data);
   double stddev = CalculateStdDev(data, mean);
   
   // Z-score for common confidence levels (approximation)
   double zScore = 1.96; // 95% confidence
   if(confidence == 0.99) zScore = 2.576;
   else if(confidence == 0.90) zScore = 1.645;
   
   double margin = zScore * stddev / MathSqrt(n);
   
   lower = mean - margin;
   upper = mean + margin;
   
   return true;
}

//+------------------------------------------------------------------+
//| Add tick data for analysis                                        |
//+------------------------------------------------------------------+
void CStatisticalCore::AddTick(double bid, double ask)
{
   if(m_tickCount >= m_maxTicks)
   {
      // Shift data: remove oldest half
      int shiftAmount = m_maxTicks / 2;
      for(int i = 0; i < m_maxTicks - shiftAmount; i++)
         m_tickData[i] = m_tickData[i + shiftAmount];
      
      m_tickCount = m_maxTicks - shiftAmount;
   }
   
   // Use mid-price for analysis
   m_tickData[m_tickCount] = (bid + ask) / 2.0;
   m_tickCount++;
}

//+------------------------------------------------------------------+
//| Clear all stored data                                             |
//+------------------------------------------------------------------+
void CStatisticalCore::ClearData()
{
   ArrayInitialize(m_tickData, 0.0);
   m_tickCount = 0;
}

#endif // STATISTICAL_CORE_MQH

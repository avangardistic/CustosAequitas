//+------------------------------------------------------------------+
//|                                              CustosAequitas.mq5  |
//|                                    Broker Integrity Sentinel EA  |
//|                                             Forensic Analysis    |
//+------------------------------------------------------------------+
#property copyright "CustosAequitas Project"
#property link      "https://github.com/avangardistic/CustosAequitas"
#property version   "1.0.0"
#property description "Broker Integrity Sentinel - Execution Forensics & Anomaly Detection"
#property strict

//--- Includes
#include <CustosAequitas\Constants.mqh>
#include <CustosAequitas\SlippageEngine.mqh>
#include <CustosAequitas\LatencyProfiler.mqh>
#include <CustosAequitas\SpreadForensics.mqh>
#include <CustosAequitas\RequoteAnalyzer.mqh>
#include <CustosAequitas\StatisticalCore.mqh>
#include <CustosAequitas\AnomalyDetector.mqh>
#include <CustosAequitas\BrokerScorer.mqh>
#include <CustosAequitas\HardeningManager.mqh>
#include <CustosAequitas\ReportGenerator.mqh>
#include <CustosAequitas\Dashboard.mqh>
#include <CustosAequitas\EventDispatcher.mqh>

//--- Input Parameters: Analysis Configuration
input group "═══════ ANALYSIS CONFIGURATION ═══════"
input int      InputMinSampleSize = 30;           // Minimum samples for preliminary analysis
input int      InputReliableSampleSize = 50;      // Minimum samples for reliable analysis  
input int      InputHighConfidenceSamples = 100;  // Samples for high confidence
input bool     InputEnablePassiveMonitoring = true;  // Passive data collection
input bool     InputEnableActiveProbing = false;     // Active test trades (DEMO ONLY)

//--- Input Parameters: Slippage Analysis
input group "═══════ SLIPPAGE ANALYSIS ═══════"
input double InputSlippageWarningThreshold = 1.5;   // Slippage bias ratio warning
input double InputSlippageDangerThreshold = 1.8;    // Slippage bias ratio danger
input bool   InputEnableSlippageAnalysis = true;    // Enable slippage forensics

//--- Input Parameters: Latency Analysis
input group "═══════ LATENCY ANALYSIS ═══════"
input int    InputLatencyWarnMs = 100;          // Latency warning threshold (ms)
input int    InputLatencyDangerMs = 200;        // Latency danger threshold (ms)
input double InputLatencyAsymmetryThreshold = 20.0; // BUY/SELL asymmetry % threshold
input bool   InputEnableLatencyAnalysis = true; // Enable latency profiling

//--- Input Parameters: Spread Analysis
input group "═══════ SPREAD ANALYSIS ═══════"
input double InputSpreadSpikeMultiplier = 2.5;  // Spread spike detection multiplier
input bool   InputEnableSpreadAnalysis = true;  // Enable spread forensics

//--- Input Parameters: Requote Analysis
input group "═══════ REQUOTE ANALYSIS ═══════"
input double InputRequoteWarnPercent = 15.0;    // Requote rate warning (%)
input double InputRequoteDangerPercent = 30.0;  // Requote rate danger (%)
input bool   InputEnableRequoteAnalysis = true; // Enable requote analysis

//--- Input Parameters: Statistical Analysis
input group "═══════ STATISTICAL ANALYSIS ═══════"
input bool   InputEnableFractalAnalysis = true;    // Enable fractal dimension (Higuchi)
input bool   InputEnableEntropyAnalysis = true;    // Enable permutation entropy
input int    InputFractalKMax = 10;                // Higuchi K-max parameter
input int    InputEntropyEmbeddingDim = 3;         // Permutation embedding dimension
input double InputConfidenceLevel = 0.95;          // Statistical confidence level

//--- Input Parameters: Broker Scoring
input group "═══════ BROKER SCORING ═══════"
input double InputSlippageWeight = 0.40;   // Slippage score weight
input double InputLatencyWeight = 0.40;    // Latency score weight
input double InputPatternWeight = 0.20;    // Pattern score weight
input bool   InputEnableConfidenceAdjustment = true; // Adjust scores by sample size

//--- Input Parameters: Hardening (DEFENSIVE ONLY)
input group "═══════ ADAPTIVE HARDENING (DEFENSIVE) ═══════"
input bool   InputEnableHardening = false;       // Disable hardening by default (OBSERVE FIRST)
input double InputBaseRiskPercent = 2.0;         // Base risk per trade (%)
input bool   InputEnableDynamicRisk = false;     // Dynamic risk adjustment (requires testing)
input bool   InputEnableStopHardening = false;   // Anti-hunt stop placement
input double InputStopBufferPips = 5.0;          // Stop loss buffer (pips)

//--- Input Parameters: Reporting
input group "═══════ REPORTING ═══════"
input bool   InputAutoGenerateReport = true;     // Auto-generate HTML reports
input int    InputReportMinTrades = 50;          // Minimum trades before report
input bool   InputExportCSV = true;              // Export data to CSV
input string InputReportDirectory = "CustosAequitas/Reports/"; // Report output directory
input string InputDataDirectory = "CustosAequitas/Data/";      // Data export directory

//--- Input Parameters: Dashboard & UI
input group "═══════ DASHBOARD & UI ═══════"
input bool   InputShowDashboard = true;          // Show live dashboard
input int    InputDashboardUpdateSec = 5;        // Dashboard update interval (seconds)
input bool   InputShowAlerts = true;             // Show alert messages
input bool   InputSoundAlerts = false;           // Enable sound alerts

//--- Input Parameters: Advanced
input group "═══════ ADVANCED ═══════"
input int    InputMaxRecords = 5000;             // Maximum records in memory
input ulong  InputMagicNumber = 20260801;        // Magic number for test orders
input bool   InputEnableLogging = true;          // Enable detailed logging

//--- Global Objects
CSlippageEngine      *g_SlippageEngine = NULL;
CLatencyProfiler     *g_LatencyProfiler = NULL;
CSpreadForensics     *g_SpreadForensics = NULL;
CRequoteAnalyzer     *g_RequoteAnalyzer = NULL;
CStatisticalCore     *g_StatisticalCore = NULL;
CAnomalyDetector     *g_AnomalyDetector = NULL;
CBrokerScorer        *g_BrokerScorer = NULL;
CHardeningManager    *g_HardeningManager = NULL;
CReportGenerator     *g_ReportGenerator = NULL;
CDashboard           *g_Dashboard = NULL;
CEventDispatcher     *g_EventDispatcher = NULL;

//--- State Variables
bool g_Initialized = false;
datetime g_LastDashboardUpdate = 0;
datetime g_LastReportTime = 0;
datetime g_StartTime = 0;
int g_BarCount = 0;
bool g_ActiveProbingAllowed = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("═══════════════════════════════════════════════════");
    Print("  CUSTOS AEQUITAS v1.0.0 - Broker Integrity Sentinel");
    Print("  Mode: ", InputEnableActiveProbing ? "ACTIVE PROBING (DEMO)" : "PASSIVE MONITORING");
    Print("═══════════════════════════════════════════════════");
    
    //--- Validate environment
    if(!ValidateEnvironment())
    {
        Print("[ERROR] Environment validation failed. EA will not run.");
        return(INIT_FAILED);
    }
    
    //--- Initialize components
    if(!InitializeComponents())
    {
        Print("[ERROR] Component initialization failed.");
        return(INIT_FAILED);
    }
    
    //--- Set up event timer
    EventSetTimer(1); // 1-second timer for periodic tasks
    
    g_StartTime = TimeCurrent();
    g_Initialized = true;
    
    Print("[INIT] CustosAequitas initialized successfully");
    Print("[INIT] Monitoring symbol: ", _Symbol);
    Print("[INIT] Sample size requirements: Min=", InputMinSampleSize, 
          " Reliable=", InputReliableSampleSize, " HighConf=", InputHighConfidenceSamples);
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("[DEINIT] Shutting down CustosAequitas...");
    
    //--- Save final data
    if(InputExportCSV && g_SlippageEngine != NULL)
    {
        string timestamp = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
        string filename = StringReplace(timestamp, ":", "_");
        g_SlippageEngine.ExportToCSV(InputDataDirectory + "slippage_" + filename + ".csv");
        g_LatencyProfiler.ExportToCSV(InputDataDirectory + "latency_" + filename + ".csv");
    }
    
    //--- Generate final report if enough data
    if(g_SlippageEngine.TotalRecords() >= InputReportMinTrades && InputAutoGenerateReport)
    {
        GenerateReport("final_report_" + IntegerToString((int)TimeCurrent()));
    }
    
    //--- Clean up objects
    CleanupObjects();
    
    EventKillTimer();
    
    Print("[DEINIT] CustosAequitas shutdown complete");
}

//+------------------------------------------------------------------+
//| Expert tick function                                               |
//+------------------------------------------------------------------+
void OnTick()
{
    if(!g_Initialized) return;
    
    //--- Passive monitoring: collect market data
    if(InputEnablePassiveMonitoring)
    {
        CollectMarketData();
    }
    
    //--- Update dashboard periodically
    UpdateDashboard();
    
    //--- Check for report generation
    CheckReportGeneration();
}

//+------------------------------------------------------------------+
//| Timer function - periodic tasks                                    |
//+------------------------------------------------------------------+
void OnTimer()
{
    if(!g_Initialized) return;
    
    //--- Periodic statistical analysis
    if(g_SlippageEngine.TotalRecords() >= InputMinSampleSize)
    {
        PerformStatisticalAnalysis();
    }
    
    //--- Check for anomalies
    if(g_AnomalyDetector != NULL)
    {
        g_AnomalyDetector.CheckAnomalies();
    }
    
    //--- Update broker score
    UpdateBrokerScore();
}

//+------------------------------------------------------------------+
//| Trade transaction handler                                          |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
    if(!g_Initialized) return;
    
    //--- Record latency for trade transactions
    if(g_LatencyProfiler != NULL && InputEnableLatencyAnalysis)
    {
        g_LatencyProfiler.RecordTransaction(trans, request, result);
    }
    
    //--- Record slippage for deal transactions
    if(trans.type == TRADE_TRANSACTION_DEAL && g_SlippageEngine != NULL)
    {
        if(InputEnableSlippageAnalysis)
        {
            g_SlippageEngine.RecordDeal(trans, result);
        }
    }
    
    //--- Record requotes/rejections
    if(g_RequoteAnalyzer != NULL && InputEnableRequoteAnalysis)
    {
        g_RequoteAnalyzer.RecordTransaction(trans, result);
    }
}

//+------------------------------------------------------------------+
//| Chart event handler                                                |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    if(id == CHARTEVENT_KEYDOWN)
    {
        //--- F1: Generate manual report
        if(lparam == VK_F1)
        {
            GenerateReport("manual_" + IntegerToString((int)TimeCurrent()));
            return;
        }
        
        //--- F2: Force test batch (only if active probing enabled)
        if(lparam == VK_F2 && InputEnableActiveProbing && g_ActiveProbingAllowed)
        {
            ExecuteTestBatch();
            return;
        }
        
        //--- F3: Toggle hardening
        if(lparam == VK_F3)
        {
            InputEnableHardening = !InputEnableHardening;
            Print("[USER] Hardening ", InputEnableHardening ? "ENABLED" : "DISABLED");
            return;
        }
    }
}

//+------------------------------------------------------------------+
//| Validate trading environment                                       |
//+------------------------------------------------------------------+
bool ValidateEnvironment()
{
    //--- Check MetaTrader build
    int build = TerminalInfoInteger(TERMINAL_BUILD);
    if(build < 2245)
    {
        Print("[ERROR] MT5 build ", build, " is too old. Minimum required: 2245");
        return false;
    }
    
    //--- Check account type (warn if live)
    if(AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_REAL)
    {
        Print("[WARNING] LIVE ACCOUNT DETECTED - Active probing disabled by default");
        Print("[WARNING] Please test on DEMO account first");
        InputEnableActiveProbing = false;
    }
    else
    {
        g_ActiveProbingAllowed = true;
    }
    
    //--- Check minimum balance
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    if(balance < 100.0)
    {
        Print("[WARNING] Account balance $", balance, " is below recommended $100 minimum");
    }
    
    //--- Check symbol
    if(!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE))
    {
        Print("[ERROR] Symbol ", _Symbol, " is not tradeable");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Initialize all components                                          |
//+------------------------------------------------------------------+
bool InitializeComponents()
{
    //--- Create statistical core first (needed by others)
    g_StatisticalCore = new CStatisticalCore();
    if(!g_StatisticalCore.Initialize(InputConfidenceLevel, InputFractalKMax, InputEntropyEmbeddingDim))
    {
        Print("[ERROR] Failed to initialize StatisticalCore");
        return false;
    }
    
    //--- Create slippage engine
    g_SlippageEngine = new CSlippageEngine();
    g_SlippageEngine.SetThresholds(InputSlippageWarningThreshold, InputSlippageDangerThreshold);
    g_SlippageEngine.SetMaxRecords(InputMaxRecords);
    
    //--- Create latency profiler
    g_LatencyProfiler = new CLatencyProfiler();
    g_LatencyProfiler.SetThresholds(InputLatencyWarnMs, InputLatencyDangerMs);
    g_LatencyProfiler.SetAsymmetryThreshold(InputLatencyAsymmetryThreshold);
    g_LatencyProfiler.SetMaxRecords(InputMaxRecords);
    
    //--- Create spread forensics
    g_SpreadForensics = new CSpreadForensics();
    g_SpreadForensics.SetSpikeMultiplier(InputSpreadSpikeMultiplier);
    g_SpreadForensics.SetMaxRecords(InputMaxRecords);
    
    //--- Create requote analyzer
    g_RequoteAnalyzer = new CRequoteAnalyzer();
    g_RequoteAnalyzer.SetThresholds(InputRequoteWarnPercent, InputRequoteDangerPercent);
    g_RequoteAnalyzer.SetMaxRecords(InputMaxRecords);
    
    //--- Create anomaly detector
    g_AnomalyDetector = new CAnomalyDetector();
    g_AnomalyDetector.SetStatisticalCore(g_StatisticalCore);
    
    //--- Create broker scorer
    g_BrokerScorer = new CBrokerScorer();
    g_BrokerScorer.SetWeights(InputSlippageWeight, InputLatencyWeight, InputPatternWeight);
    g_BrokerScorer.SetSampleSizeThresholds(InputMinSampleSize, InputReliableSampleSize, InputHighConfidenceSamples);
    g_BrokerScorer.EnableConfidenceAdjustment(InputEnableConfidenceAdjustment);
    
    //--- Create hardening manager (defensive only by default)
    g_HardeningManager = new CHardeningManager();
    g_HardeningManager.SetBaseRisk(InputBaseRiskPercent);
    g_HardeningManager.SetStopBuffer(InputStopBufferPips);
    g_HardeningManager.Enable(InputEnableHardening);
    
    //--- Create report generator
    g_ReportGenerator = new CReportGenerator();
    g_ReportGenerator.SetDirectories(InputReportDirectory, InputDataDirectory);
    g_ReportGenerator.SetMinTradesForReport(InputReportMinTrades);
    
    //--- Create dashboard
    g_Dashboard = new CDashboard();
    g_Dashboard.SetUpdateInterval(InputDashboardUpdateSec);
    g_Dashboard.SetVisible(InputShowDashboard);
    
    //--- Create event dispatcher
    g_EventDispatcher = new CEventDispatcher();
    
    //--- Link components together
    LinkComponents();
    
    return true;
}

//+------------------------------------------------------------------+
//| Link components together                                           |
//+------------------------------------------------------------------+
void LinkComponents()
{
    //--- Pass data sources to analyzer
    g_AnomalyDetector.SetSlippageEngine(g_SlippageEngine);
    g_AnomalyDetector.SetLatencyProfiler(g_LatencyProfiler);
    g_AnomalyDetector.SetSpreadForensics(g_SpreadForensics);
    g_AnomalyDetector.SetRequoteAnalyzer(g_RequoteAnalyzer);
    
    //--- Pass data sources to scorer
    g_BrokerScorer.SetSlippageEngine(g_SlippageEngine);
    g_BrokerScorer.SetLatencyProfiler(g_LatencyProfiler);
    g_BrokerScorer.SetStatisticalCore(g_StatisticalCore);
    
    //--- Pass scorer to hardening manager
    g_HardeningManager.SetBrokerScorer(g_BrokerScorer);
    
    //--- Pass data sources to report generator
    g_ReportGenerator.SetSlippageEngine(g_SlippageEngine);
    g_ReportGenerator.SetLatencyProfiler(g_LatencyProfiler);
    g_ReportGenerator.SetSpreadForensics(g_SpreadForensics);
    g_ReportGenerator.SetRequoteAnalyzer(g_RequoteAnalyzer);
    g_ReportGenerator.SetBrokerScorer(g_BrokerScorer);
    g_ReportGenerator.SetAnomalyDetector(g_AnomalyDetector);
    
    //--- Pass scorer to dashboard
    g_Dashboard.SetBrokerScorer(g_BrokerScorer);
    g_Dashboard.SetSlippageEngine(g_SlippageEngine);
    g_Dashboard.SetLatencyProfiler(g_LatencyProfiler);
    g_Dashboard.SetSpreadForensics(g_SpreadForensics);
    g_Dashboard.SetRequoteAnalyzer(g_RequoteAnalyzer);
}

//+------------------------------------------------------------------+
//| Collect market data (passive monitoring)                           |
//+------------------------------------------------------------------+
void CollectMarketData()
{
    //--- Record spread
    if(InputEnableSpreadAnalysis && g_SpreadForensics != NULL)
    {
        long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
        g_SpreadForensics.RecordSpread(TimeCurrent(), spread, SymbolInfoDouble(_Symbol, SYMBOL_BID), SymbolInfoDouble(_Symbol, SYMBOL_ASK));
    }
    
    //--- Record tick data for fractal/entropy analysis
    if((InputEnableFractalAnalysis || InputEnableEntropyAnalysis) && g_StatisticalCore != NULL)
    {
        double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        g_StatisticalCore.AddTick(bid, ask);
    }
}

//+------------------------------------------------------------------+
//| Perform statistical analysis                                       |
//+------------------------------------------------------------------+
void PerformStatisticalAnalysis()
{
    if(g_StatisticalCore == NULL) return;
    
    //--- Calculate fractal dimension if enabled
    if(InputEnableFractalAnalysis)
    {
        double hurst = g_StatisticalCore.CalculateHurstExponent();
        g_AnomalyDetector.SetFractalDimension(hurst);
    }
    
    //--- Calculate permutation entropy if enabled
    if(InputEnableEntropyAnalysis)
    {
        double entropy = g_StatisticalCore.CalculatePermutationEntropy();
        g_AnomalyDetector.SetEntropy(entropy);
    }
}

//+------------------------------------------------------------------+
//| Update broker score                                                |
//+------------------------------------------------------------------+
void UpdateBrokerScore()
{
    if(g_BrokerScorer == NULL) return;
    
    ENUM_BROKER_GRADE grade = g_BrokerScorer.CalculateGrade();
    double score = g_BrokerScorer.GetCurrentScore();
    double confidence = g_BrokerScorer.GetConfidence();
    
    //--- Update hardening based on score
    if(g_HardeningManager != NULL && InputEnableHardening)
    {
        g_HardeningManager.UpdateScore(grade, score, confidence);
    }
}

//+------------------------------------------------------------------+
//| Update dashboard display                                           |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
    if(!InputShowDashboard || g_Dashboard == NULL) return;
    
    datetime now = TimeCurrent();
    if(now - g_LastDashboardUpdate >= InputDashboardUpdateSec)
    {
        g_Dashboard.Update();
        g_LastDashboardUpdate = now;
    }
}

//+------------------------------------------------------------------+
//| Check if report should be generated                                |
//+------------------------------------------------------------------+
void CheckReportGeneration()
{
    if(!InputAutoGenerateReport) return;
    if(g_SlippageEngine == NULL) return;
    
    int totalRecords = g_SlippageEngine.TotalRecords();
    if(totalRecords >= InputReportMinTrades)
    {
        datetime now = TimeCurrent();
        // Generate report every hour after reaching threshold
        if(now - g_LastReportTime >= 3600)
        {
            GenerateReport("auto_" + IntegerToString((int)now));
            g_LastReportTime = now;
        }
    }
}

//+------------------------------------------------------------------+
//| Generate forensic report                                           |
//+------------------------------------------------------------------+
void GenerateReport(string prefix)
{
    if(g_ReportGenerator == NULL) return;
    
    string filename = prefix + "_" + _Symbol + "_" + IntegerToString((int)TimeCurrent());
    
    if(g_ReportGenerator.GenerateHTMLReport(filename))
    {
        Print("[REPORT] Generated: ", filename, ".html");
    }
    else
    {
        Print("[ERROR] Failed to generate report: ", filename);
    }
    
    if(InputExportCSV)
    {
        g_ReportGenerator.ExportCSVData(prefix);
    }
}

//+------------------------------------------------------------------+
//| Execute test batch (active probing)                                |
//+------------------------------------------------------------------+
void ExecuteTestBatch()
{
    if(!g_ActiveProbingAllowed)
    {
        Print("[WARNING] Active probing not allowed on this account");
        return;
    }
    
    Print("[PROBE] Executing test batch...");
    //--- Implementation would go here for controlled micro-transactions
    //--- This is intentionally minimal to emphasize OBSERVATION-FIRST approach
}

//+------------------------------------------------------------------+
//| Clean up all objects                                               |
//+------------------------------------------------------------------+
void CleanupObjects()
{
    if(g_SlippageEngine != NULL) delete g_SlippageEngine;
    if(g_LatencyProfiler != NULL) delete g_LatencyProfiler;
    if(g_SpreadForensics != NULL) delete g_SpreadForensics;
    if(g_RequoteAnalyzer != NULL) delete g_RequoteAnalyzer;
    if(g_StatisticalCore != NULL) delete g_StatisticalCore;
    if(g_AnomalyDetector != NULL) delete g_AnomalyDetector;
    if(g_BrokerScorer != NULL) delete g_BrokerScorer;
    if(g_HardeningManager != NULL) delete g_HardeningManager;
    if(g_ReportGenerator != NULL) delete g_ReportGenerator;
    if(g_Dashboard != NULL) delete g_Dashboard;
    if(g_EventDispatcher != NULL) delete g_EventDispatcher;
}

//+------------------------------------------------------------------+
